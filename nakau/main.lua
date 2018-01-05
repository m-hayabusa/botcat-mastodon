--
-- Created by IntelliJ IDEA.
-- User: hs-sh
-- Date: 18/01/04
-- Time: 13:57
-- To change this template use File | Settings | File Templates.
--
main = function()
debug = false

    local placename = "江ノ島"
    placename = io.read()

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

    -- GeoNamesで地名をキーにして取得
    local xml = http.request("http://api.geonames.org/postalCodeSearch?maxRows=1&username=hayabusa&placename="..urlencode(placename))

    -- local xml = [[
    -- <geonames>
    -- <totalResultsCount>2</totalResultsCount>
    -- <code>
    -- <postalcode>251-0036</postalcode>
    -- <name>Enoshima</name>
    -- <countryCode>JP</countryCode>
    -- <lat>35.30117</lat>
    -- <lng>139.48125</lng>
    -- <adminCode1>19</adminCode1>
    -- <adminName1>Kanagawa Ken</adminName1>
    -- <adminCode2>1864091</adminCode2>
    -- <adminName2>Fujisawa Shi</adminName2>
    -- <adminCode3/>
    -- <adminName3/>
    -- </code>
    -- </geonames>
    -- ]]

    local handler = require("xmlhandler.tree")
    local parser = xml2lua.parser(handler)
    parser:parse(xml)

    if (handler.root.geonames.totalResultsCount == 0 or handler.root.geonames.code == nil) then
        print("それは・・・どこですか？")
        os.exit(0)
    end

    if debug then
        for k, v in pairs(handler.root.geonames.code) do
            print (k, v)
        end
    end

    lng = handler.root.geonames.code.lng
    lat = handler.root.geonames.code.lat

    if debug then
        print("lat: " .. lat)
        print("lng: " .. lng)

        print("Map: " .. "http://maps.nakau.co.jp/p/zen009/nmap.htm"
                .."?lat=" .. lat
                .."&lon=" .. lng)
    end

    local cgi_url = "http://maps.nakau.co.jp/p/zen009/zdcemaphttp2.cgi?"
    cgi_url = cgi_url .. "target=" ..  urlencode("http://127.0.0.1/p/zen009/nlist.htm?"
            .."&lat="..lat
            .."&lon="..lng
            .."&latlon="..lat-0.098856209 .. ',' .. lng-0.159068627 .. ',' .. lat+0.9885621 .. ',' .. lng+0.159068628
            .."&srchplace=" .. ',' .. lat .. ',' .. lng
            .."&radius=0&jkn=(COL_02:1%20AND%20COL_04:6)"
            .."&page=0&cond1=1&cond2=1&&his=nm"
            .."&PARENT_HTTP_HOST=maps.nakau.co.jp")
    cgi_url = cgi_url .. "&zdccnt=18" .. "&enc=EUC" .. "&encodeflg=0"

    --print("cgi_url: "..cgi_url)

    local htm = http.request(cgi_url)

     --　CGIから帰ってくるのがEUC-JPなのでUTF-8に変換
    local iconv = require("iconv")
    cd = iconv.new("UTF-8", "EUC-JP")
    htm = cd:iconv(htm)

    --local htm = [[ZdcEmapHttpResult[18] = '<div id="kyotenList">\n\t<div id="kyotenListHd">\n\t\t<table id="kyotenListHeader">\n\t\t\t<tr>\n\t\t\t\t<td class="kyotenListTitle">最寄り店舗一覧</td>\n\t\t\t</tr>\n\t\t</table>\n\t</div>\n\t<div id="kyotenListDt">\n\t\t<table id="kyotenListTable">\n\t\t\t\t\t\t<tr>\n\t\t\t\t<td>\n\t\t\t\t\t<div class="kyotenListName">\n\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/icon_select.cgi?cid=zen000&icon_id=50" />\n\t\t\t\t\t\t&nbsp;\n\t\t\t\t\t\t<a href="http://maps.nakau.co.jp/p/zen009/dtl/ID0200454/?&cond1=1&cond2=1&&his=nm&srchplace=,35.30117,139.48125"\n\t\t\t\t\t\tonMouseOver="ZdcEmapMapCursorSet(\'35.3357217\',\'139.4884031\');ZdcEmapMapFrontShopMrk(0);" onMouseOut="ZdcEmapMapCursorRemove();"\n\t\t\t\t\t\t>\n\t\t\t\t\t\t藤沢駅北口店\n\t\t\t\t\t\t</a>\n\t\t\t\t\t\t\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t〒251-0052&nbsp;\n\t\t\t\t\t\t\t\t\t\t\t\t神奈川県藤沢市藤沢438-6FIC藤沢ﾋﾞﾙ1F\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=028" alt="デザート" title="デザート">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=029" alt="朝食" title="朝食">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=036" alt="定食" title="定食">\n\t\t\t\t\t\t\t\t\t\t\t\t<br>\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=0412" alt="禁煙" title="禁煙">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</div>\n\t\t\t\t</td>\n\t\t\t</tr>\n\t\t\t\t\t<tr>\n\t\t\t\t<td>\n\t\t\t\t\t<div class="kyotenListName">\n\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/icon_select.cgi?cid=zen000&icon_id=50" />\n\t\t\t\t\t\t&nbsp;\n\t\t\t\t\t\t<a href="http://maps.nakau.co.jp/p/zen009/dtl/ID0200087/?&cond1=1&cond2=1&&his=nm&srchplace=,35.30117,139.48125"\n\t\t\t\t\t\tonMouseOver="ZdcEmapMapCursorSet(\'35.3335131\',\'139.4514869\');ZdcEmapMapFrontShopMrk(1);" onMouseOut="ZdcEmapMapCursorRemove();"\n\t\t\t\t\t\t>\n\t\t\t\t\t\t辻堂店\n\t\t\t\t\t\t</a>\n\t\t\t\t\t\t\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t〒251-0047&nbsp;\n\t\t\t\t\t\t\t\t\t\t\t\t神奈川県藤沢市辻堂1-1-10\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=028" alt="デザート" title="デザート">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=029" alt="朝食" title="朝食">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=036" alt="定食" title="定食">\n\t\t\t\t\t\t\t\t\t\t\t\t<br>\n\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=039" alt="24時間営業" title="24時間営業">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=0412" alt="禁煙" title="禁煙">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</div>\n\t\t\t\t</td>\n\t\t\t</tr>\n\t\t\t\t\t<tr>\n\t\t\t\t<td>\n\t\t\t\t\t<div class="kyotenListName">\n\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/icon_select.cgi?cid=zen000&icon_id=50" />\n\t\t\t\t\t\t&nbsp;\n\t\t\t\t\t\t<a href="http://maps.nakau.co.jp/p/zen009/dtl/ID0200256/?&cond1=1&cond2=1&&his=nm&srchplace=,35.30117,139.48125"\n\t\t\t\t\t\tonMouseOver="ZdcEmapMapCursorSet(\'35.3327425\',\'139.4058861\');ZdcEmapMapFrontShopMrk(2);" onMouseOut="ZdcEmapMapCursorRemove();"\n\t\t\t\t\t\t>\n\t\t\t\t\t\tイオン茅ヶ崎中央店\n\t\t\t\t\t\t</a>\n\t\t\t\t\t\t\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t〒253-0041&nbsp;\n\t\t\t\t\t\t\t\t\t\t\t\t神奈川県茅ヶ崎市茅ヶ崎3-5-16イオン茅ヶ崎中央店内\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=027" alt="お子様メニュー" title="お子様メニュー">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=028" alt="デザート" title="デザート">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=036" alt="定食" title="定食">\n\t\t\t\t\t\t\t\t\t\t\t\t<br>\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=0412" alt="禁煙" title="禁煙">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</div>\n\t\t\t\t</td>\n\t\t\t</tr>\n\t\t\t\t\t<tr>\n\t\t\t\t<td>\n\t\t\t\t\t<div class="kyotenListName">\n\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/icon_select.cgi?cid=zen000&icon_id=50" />\n\t\t\t\t\t\t&nbsp;\n\t\t\t\t\t\t<a href="http://maps.nakau.co.jp/p/zen009/dtl/ID0200201/?&cond1=1&cond2=1&&his=nm&srchplace=,35.30117,139.48125"\n\t\t\t\t\t\tonMouseOver="ZdcEmapMapCursorSet(\'35.3244719\',\'139.3502569\');ZdcEmapMapFrontShopMrk(3);" onMouseOut="ZdcEmapMapCursorRemove();"\n\t\t\t\t\t\t>\n\t\t\t\t\t\t平塚西口店\n\t\t\t\t\t\t</a>\n\t\t\t\t\t\t\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t〒254-0043&nbsp;\n\t\t\t\t\t\t\t\t\t\t\t\t神奈川県平塚市紅谷町16-2平塚西口会館\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=028" alt="デザート" title="デザート">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=029" alt="朝食" title="朝食">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=036" alt="定食" title="定食">\n\t\t\t\t\t\t\t\t\t\t\t\t<br>\n\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=039" alt="24時間営業" title="24時間営業">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=0412" alt="禁煙" title="禁煙">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</div>\n\t\t\t\t</td>\n\t\t\t</tr>\n\t\t\t\t\t<tr>\n\t\t\t\t<td>\n\t\t\t\t\t<div class="kyotenListName">\n\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/icon_select.cgi?cid=zen000&icon_id=50" />\n\t\t\t\t\t\t&nbsp;\n\t\t\t\t\t\t<a href="http://maps.nakau.co.jp/p/zen009/dtl/ID0200049/?&cond1=1&cond2=1&&his=nm&srchplace=,35.30117,139.48125"\n\t\t\t\t\t\tonMouseOver="ZdcEmapMapCursorSet(\'35.3211717\',\'139.3342567\');ZdcEmapMapFrontShopMrk(4);" onMouseOut="ZdcEmapMapCursorRemove();"\n\t\t\t\t\t\t>\n\t\t\t\t\t\t湘南大磯店\n\t\t\t\t\t\t</a>\n\t\t\t\t\t\t\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t〒255-0001&nbsp;\n\t\t\t\t\t\t\t\t\t\t\t\t神奈川県中郡大磯町高麗3-4-16\n\t\t\t\t\t</div>\n\t\t\t\t\t\t\t\t\t\t<div class="kyotenListData">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=028" alt="デザート" title="デザート">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=029" alt="朝食" title="朝食">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=036" alt="定食" title="定食">\n\t\t\t\t\t\t\t\t\t\t\t\t<br>\n\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=039" alt="24時間営業" title="24時間営業">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=0412" alt="禁煙" title="禁煙">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<img src="http://maps.nakau.co.jp/cgi/sys_icon_select.cgi?cid=zen000&icon_id=048" alt="駐車場" title="駐車場">\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</div>\n\t\t\t\t</td>\n\t\t\t</tr>\n\t\t\t\t</table>\n\t</div>\n\t<div class="custKyotenListHd">\n\t\t<table class="custKyotenListHeader">\n\t\t\t<tr>\n\t\t\t\t<td class="custKyotenListPage">\n\t\t\t\t\t\t\t\t\t\t1-5件/10件中\n\t\t\t\t\t\t\t\t\t\t&nbsp;<input type="button" class="custPageButton" onClick="javascript:ZdcEmapSearchShopListClick(1);" value="次へ" />\n\t\t\t\t\t\t\t\t\t</td>\n\t\t\t</tr>\n\t\t</table>\n\t</div>\n</div>\n';]]

    htm = string.gsub(htm, "ZdcEmapHttpResult%[[0-9]-%]% %=% %'<div% id%=\"kyotenList\">\\n\\t<div% id%=\"kyotenListHd\">\\n\\t\\t<table% id%=\"kyotenListHeader\">\\n\\t\\t\\t<tr>\\n\\t\\t\\t\\t<td% class%=\"kyotenListTitle\">最寄り店舗一覧</td>\\n\\t\\t\\t</tr>\\n\\t\\t</table>\\n\\t</div>\\n\\t<div% id%=\"kyotenListDt\">\\n\\t\\t","")
    htm = string.gsub(htm, "\\n\\t</div>\\n\\t<div% class%=\"custKyotenListHd\">\\n\\t\\t<table% class%=\"custKyotenListHeader\">\\n\\t\\t\\t<tr>\\n\\t\\t\\t\\t<td% class%=\"custKyotenListPage\">\\n\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t1%-5件/10件中\\n\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t%&nbsp;<input% type%=\"button\"% class%=\"custPageButton\"% onClick%=\"javascript%:ZdcEmapSearchShopListClick%(1%);\"% value%=\"次へ\"% />\\n\\t\\t\\t\\t\\t\\t\\t\\t\\t</td>\\n\\t\\t\\t</tr>\\n\\t\\t</table>\\n\\t</div>\\n</div>\\n%';$", '')

    -- 邪魔なものを消す
    htm = string.gsub(htm, "\\n", ' ')
    htm = string.gsub(htm, "\\t", '')
    htm = string.gsub(htm, "&nbsp;", '')
    htm = string.gsub(htm, "<br>",'')
    htm = string.gsub(htm, "onMouse.-;\"", '')
    htm = string.gsub(htm, "onClick.-;\"", '')
    htm = string.gsub(htm, "<table% id%=\"kyotenListTable\">(.-)</table>", '<nakau>%1</nakau>')
    htm = string.gsub(htm, "<img% src%=\"http%://maps.nakau.co.jp/cgi/icon_select.cgi%?cid%=zen000&icon_id=50\" />", '') -- なか卯のロゴ
    htm = string.gsub(htm, "<tr>% <td>% <div% class%=\"kyotenListName\">(.-)</td>% </tr>", "<kyoten>%1</kyoten>") -- tr td divを１タグに
    htm = string.gsub(htm, "\"% >", "\">")

    -- 住所の部分を整形
    htm = string.gsub(htm, "<div% class%=\"kyotenListData\"> 〒(.-)</div>", '<address> 〒%1</address>')

    -- お店のタイプを整形
    htm = string.gsub(htm, "<div% class%=\"kyotenListData\">(.-)</div>", "<list>%1</list>")
    htm = string.gsub(htm, "<img% src%=\"http%://maps.nakau.co.jp/cgi/sys_icon_select.cgi%?cid%=zen000&icon_id=[0-9]-\"% alt%=\"(.-)\"% title%=\".-\">", "<data>%1</data>")

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

        print (placename .. "(" .. handler.root.geonames.code.countryCode .. " " .. handler.root.geonames.code.adminName1 .. " " .. handler.root.geonames.code.adminName2 .. ") の最寄りのなか卯は、"..handler.root.nakau.kyoten[1].name.."で、".."以下のものを取り扱っています： ")

        for l, w in pairs(handler.root.nakau.kyoten[1].list.data) do
            print (w)
        end

        print ("場所は、"..handler.root.nakau.kyoten[1].address.."で、URLは "..handler.root.nakau.kyoten[1].url.." です")
        os.exit(0)
    else
        print ("ごめんなさい・・・。 "..placename .. "(" .. handler.root.geonames.code.countryCode .. " " .. handler.root.geonames.code.adminName1 .. " " .. handler.root.geonames.code.adminName2 .. ") の最寄りのなか卯は見つけられませんでした・・・。")
        os.exit(0)
    end
end

main()
