--
-- Created by IntelliJ IDEA.
-- User: hs-sh
-- Date: 18/01/04
-- Time: 13:57
-- To change this template use File | Settings | File Templates.
--
debug = false

local http    = require ("socket.http")
package.path = package.path..";./lib/xml2lua/?.lua"
package.cpath = package.cpath .. ";./lib/lua-iconv-7/?.so;"
require ("xml2lua")

urlencode = function(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])",
            function(c)
                return string.format("%%%02X",string.byte(c))
            end)
        str = string.gsub (str, " ", "+")
        str = string.gsub (str, "%%2E",".")
        str = string.gsub (str, "%%28","(")
        str = string.gsub (str, "%%29",")")
    end
    return str
end

getLocation = function(placename)
    if placename == nil then
        return nil
    end

    -- Yahoo! Weather APIで地名をキーにして取得
    local xml = http.request("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=\""..urlencode(placename)..'")')
    local handler = require("xmlhandler.tree")
    local parser = xml2lua.parser(handler)
    xml = string.gsub(xml,"yweather:","yweather_") --テーブル名に:が入ってめんどくさい
    xml = string.gsub(xml,"geo:","geo_") --テーブル名に:が入ってめんどくさい
    parser:parse(xml)

    if handler.root.query.results.channel == nil then
        return nil
    end

    return handler.root.query.results.channel.item.geo_lat[1],handler.root.query.results.channel.item.geo_long[1], handler.root.query.results.channel.yweather_location._attr.country.." "..handler.root.query.results.channel.yweather_location._attr.region.." "..handler.root.query.results.channel.yweather_location._attr.city
end

main = function(placename)
    local lat, lng, location= getLocation(placename)

    if location == nil then
        location = "❔"
    end

    if lat == nil or lng == nil then
        return {2, "それは・・・どこですか？"}
    end

    if debug then
        print("lat: " .. lat)
        print("lng: " .. lng)

        print("Map: " .. "http://maps.sukiya.jp/p/zen004/nmap.htm"
                .."?lat=" .. lat
                .."&lon=" .. lng)
    end

    local cgi_url = "http://maps.sukiya.jp/p/zen004/zdcemaphttp2.cgi?"
    cgi_url = cgi_url .. "target=" ..  urlencode("http://127.0.0.1/p/zen004/nlist.htm?"
            .."&lat="..lat
            .."&lon="..lng
            .."&latlon="..lat-0.098856209 .. ',' .. lng-0.159068627 .. ',' .. lat+0.9885621 .. ',' .. lng+0.159068628
            .."&srchplace=" .. ',' .. lat .. ',' .. lng
            .."&radius=0&jkn=(COL_02:1%20AND%20COL_04:2)"
            .."&page=0&cond1=1&cond2=1&&his=nm"
            .."&PARENT_HTTP_HOST=maps.sukiya.jp")
    cgi_url = cgi_url .. "&zdccnt=5" .. "&enc=EUC" .. "&encodeflg=0"

    --print("cgi_url: "..cgi_url)

    local htm = http.request(cgi_url)

     --　CGIから帰ってくるのがEUC-JPなのでUTF-8に変換
    local iconv = require("iconv")
    cd = iconv.new("UTF-8", "EUC-JP")
    htm = cd:iconv(htm)

    htm = string.gsub(htm, "ZdcEmapHttpResult%[[0-9]-%]% %=% %'<div% id%=\"kyotenList\">\\n\\t<div% id%=\"kyotenListHd\">\\n\\t\\t<table% id%=\"kyotenListHeader\">\\n\\t\\t\\t<tr>\\n\\t\\t\\t\\t<td% class%=\"kyotenListTitle\">最寄り店舗一覧</td>\\n\\t\\t\\t</tr>\\n\\t\\t</table>\\n\\t</div>\\n\\t<div% id%=\"kyotenListDt\">\\n\\t\\t","")
    htm = string.gsub(htm, "\\n\\t</div>\\n\\t<div% class%=\"custKyotenListHd\">\\n\\t\\t<table% class%=\"custKyotenListHeader\">\\n\\t\\t\\t<tr>\\n\\t\\t\\t\\t<td% class%=\"custKyotenListPage\">\\n\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t1%-5件/10件中\\n\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t%&nbsp;<input% type%=\"button\"% class%=\"custPageButton\"% onClick%=\"javascript%:ZdcEmapSearchShopListClick%(1%);\"% value%=\"次へ\"% />\\n\\t\\t\\t\\t\\t\\t\\t\\t\\t</td>\\n\\t\\t\\t</tr>\\n\\t\\t</table>\\n\\t</div>\\n</div>\\n%';$", '')

    -- 邪魔なものを消す
    htm = string.gsub(htm, "\\n", ' ')
    htm = string.gsub(htm, "\\t", '')
    htm = string.gsub(htm, "&nbsp;", '')
    htm = string.gsub(htm, "<br>",'')
    htm = string.gsub(htm, "onMouse.-;\"", '')
    htm = string.gsub(htm, "onClick.-;\"", '')
    htm = string.gsub(htm, "<table% id%=\"kyotenListTable\">(.-)</table>", '<sukiya>%1</sukiya>')
    htm = string.gsub(htm, "<img% src%=\"http%://maps.sukiya.jp/cgi/icon_select.cgi%?cid%=zen000&icon_id=50\" />", '') -- すき家のロゴ
    htm = string.gsub(htm, "<tr>% <td>% <div% class%=\"kyotenListName\">(.-)</td>% </tr>", "<kyoten>%1</kyoten>") -- tr td divを１タグに
    htm = string.gsub(htm, "\"% >", "\">")

    -- 住所の部分を整形
    htm = string.gsub(htm, "<div% class%=\"kyotenListData\"> 〒(.-)</div>", '<address> 〒%1</address>')

    -- お店のタイプを整形
    htm = string.gsub(htm, "<div% class%=\"kyotenListData\">(.-)</div>", "<list>%1</list>")
    htm = string.gsub(htm, "<img% src%=\"http%://maps.sukiya.jp/cgi/sys_icon_select.cgi%?cid%=zen000&icon_id=[0-9]-\"% alt%=\"(.-)\"% title%=\".-\">", "<data>%1</data>")

    -- 店名とURLを整形
    --htm = string.gsub(htm, "<a href=\"(.-(.))\" *>", '<url>%1</url>')
    htm = string.gsub(htm, "<a href=\"(.-)?.-\" *> (.-)</a> *</div>", "<url> %1 </url> <name> %2 </name>")
    --htm = string.gsub(htm, "<url> (.-)?.- </url>", "</url>")

    local r = -1
    while r ~= 0 do  -- スペースが２つ重なっているところがなくなるまで繰り返し
        htm,r = string.gsub(htm, "  ", ' ')
    end

    --htm = string.gsub(htm, "<a href=\"(.-(.))\" *>", '<url>%1</url>')

    if debug then
        print (htm)
    end

    if select(2, string.gsub(htm, "最寄店舗がありませんでした", "")) == 0 then
        local handler = require("xmlhandler.tree")
        local parser = xml2lua.parser(handler)
        parser:parse(htm)

        local ret = placename .. "(" ..location .. ") の最寄りのすき家は、"..handler.root.sukiya.kyoten[1].name.."で、".."以下のものを取り扱っています： "

        for l, w in pairs(handler.root.sukiya.kyoten[1].list.data) do
            ret = ret .. w .. "、 "
        end

        ret = ret .. "\n場所は、"..handler.root.sukiya.kyoten[1].address.."で、URLは "..handler.root.sukiya.kyoten[1].url.." です。"
        return {0, ret}
    else
        local ret = "ごめんなさい・・・。 "..placename .. "(" .. location .. ") の最寄りのすき家は見つけられませんでした・・・。"
        return {1, ret}
    end
end

local ret = main(io.read())
print(ret[1].." "..ret[2])
