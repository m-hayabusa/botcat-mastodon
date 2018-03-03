let is_running = 1;
let eti = 0;
let config = require('./config');
let fetch = require('node-fetch');

let Filledknzk = {depth:null, dead_mode: null};

let WebSocketClient = require('websocket').client;
let client = new WebSocketClient();

client.on('connectFailed', function(error) {
    console.log('Connect Error: ' + error.toString());
});

client.on('connect', function(connection) {
    console.log('WebSocket Client Connected');
                                    // post(":googlecat:​ 起動したにゃ");

    connection.on('error', function(error) {
        console.log("Connection Error: " + error.toString());
    });
    connection.on('close', function() {
        console.log('AkariBot Connection Closed');
        //鯖落ち
    });
    connection.on('message', function(message) {
        //console.log(message);
        try {
            if (message.type === 'utf8') {
                let json = JSON.parse(JSON.parse(message.utf8Data).payload);
                if (json['account']) {
                    let acct = json['account']['acct'];
                    let text = json['content'];
                    if (acct !== config.user) {
                        if (is_running) {
                            //終了
                            if (acct === config.admin || acct === "imncls" || acct === "_5" || acct === "Knzk") {
                                if (text.match(/!stop/i)) {
                                    if (acct !== config.admin) {
                                        post("@"+acct+" 終了しました。", {}, "direct");
                                    }
                                    post("終了したにゃ", {}, "public", true);
                                    change_running(0);
                                    console.log("OK:STOP:@"+acct);
                                }
                            }

                            text = text.replace(/<("[^"]*"|'[^']*'|[^'">])*>/g,"");
                            let regStart = /(@cat |(猫|ねこ|Cat)(Bot|ぼっと))、?/i

                            //最後にあかりたそに埋められた神崎おにいさん
                             if (acct == "yuzu") { // yuzu(@knzk.me): あかりたそ
                                 if (json['spoiler_text'].match(/ｺﾞｺﾞｺﾞｺﾞｺﾞｺﾞ.../i)) {
                                     Filledknzk.depth = text.replace(/^.*?を埋めたら/,"").replace(/メートルぐらい.*?$/,"");;
                                     if (text.match(/マグマに落ちちゃった/)){
                                         Filledknzk.dead_mode = "lava";
                                         Filledknzk.depth = null;
                                     }else if (text.match(/溺れちゃった/)) {
                                         Filledknzk.dead_mode = "water";
                                     }else{
                                         Filledknzk.dead_mode = null;
                                     }
                                     // post("あかりたそが神崎おにいさんを埋めました: 深さ " + Filledknzk.depth+ "\t死因 "+ Filledknzk.dead_mode);
                                     console.log("あかりたそが神崎おにいさんを埋めました: 深さ " + Filledknzk.depth+ "\t死因 "+ Filledknzk.dead_mode);
                                 }
                             }

                             //メイン部分
                             if (text.match(regStart)) {
                                rt(json['id']);
                                fav(json['id']);

                                text = text.replace(regStart,"");

                                if (text.match(/(掘り)/i)) {
                                    if (text.match(/(神崎|おにいさん|お兄さん)/i)) {
                                        let name = "knzk";
                                        let diggedDepth = (Math.floor( Math.random() * (30) ) + 1);
                                        console.log("神崎おにいさんを掘り出します: " + "深さは" + Filledknzk.depth + "\t死因は" +Filledknzk.dead_mode);

                                        if (!Filledknzk.depth) {
                                            Filledknzk.depth = null;
                                        }

                                        let talktext = "@"+acct+" と一緒に";
                                        if (Filledknzk.depth < diggedDepth) {
                                            talktext += Filledknzk.depth + "mぐらい掘って､";
                                            if(Filledknzk.dead_mode == "water"){
                                                talktext += "水の中からおにいさんをみつけたにゃ！\n溺れちゃってたけど・・・";
                                            } else if(Filledknzk.dead_mode == "lava"){
                                                talktext += "おにいさんを掘り出そうとして"+diggedDepth+"mぐらい掘ってみたけど､"
                                                talktext += "溶岩が出てきちゃったから諦めたにゃ…｡";
                                            } else {
                                                talktext += "岩の中からおにいさんをみつけたにゃ！";
                                            }
                                        } else {
                                            talktext += "おにいさんを掘り出そうとして"+diggedDepth+"mぐらい掘ってみたけど､";
                                            talktext += "見つからなかったにゃ…｡";
                                        }

                                        post(talktext +"\n\n\n"+horihori(Filledknzk.depth, name, Filledknzk.dead_mode, diggedDepth), {cw: "うみゃみゃみゃーっ！"});
                                        console.log(talktext);

                                        Filledknzk.depth = null;
                                        let rand_dead = Math.floor( Math.random() * 21 );
                                        if (rand_dead > 15) {
                                            Filledknzk.dead_mode = "lava";
                                        } else if (rand_dead > 10) {
                                            Filledknzk.dead_mode = "water";
                                        } else {
                                            Filledknzk.dead_mode = null;
                                        }
                                    }
                                }

                                let regNearest = /(の最寄り|から(一|1|１)番近い|から近い).*$/i
                                if (text.match(regNearest)) {
                                    if (text.match(/(なか卯)/i)) {
                                        var placename = text.replace(regNearest,"");
                                        var exec = require('child_process').execSync;
                                        var result = exec('cd ./nakau;'+'echo '+ placename +' | lua ./main.lua');
                                        console.log("result= "+result);
                                        post("@"+acct+" "+result, {in_reply_to_id: json['id']}, json['visibility']);
                                        console.log("最寄り: なか卯:\t"+acct+"\t場所: "+placename);
                                    } else if (text.match(/(すき家)/i)) {
                                        var placename = text.replace(regNearest,"");
                                        var exec = require('child_process').execSync;
                                        var result = exec('cd ./sukiya;'+'echo '+ placename +' | lua ./main.lua');
                                        console.log("result= "+result);
                                        post("@"+acct+" "+result, {in_reply_to_id: json['id']}, json['visibility']);
                                        console.log("最寄り: すき家:\t"+acct+"\t場所: "+placename);
                                    } else {
                                        post("@"+acct+" えっ\n\n・・・えっ？", {in_reply_to_id: json['id']},json['visibility']);
                                        console.log("最寄り: 不明:\t"+acct+"\t " + text);
                                    }
                                }
                             }
                        } else {
                            if (acct === config.admin) {
                                if (text.match(/!start/i) || text.match(/(猫Bot|ねこぼっと)(起動|おきて|起きて)/i)) {
                                    post(":googlecat:​ 起動したにゃ");
                                    change_running(1);
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            post("エラーが発生したです\n止まるです");
            console.log (e);
            change_running(0);

            post("@"+config.admin+"  【エラー検知】\n\n"+ e, {}, "direct");
        }
    });
});

client.connect("wss://" + config.domain + "/api/v1/streaming/?access_token=" + config.token + "&stream=public:local");


// ここからいろいろ
function fav(id) {
    fetch("https://" + config.domain + "/api/v1/statuses/"+id+"/favourite", {
        headers: {'content-type': 'application/json', 'Authorization': 'Bearer '+config.token},
        method: 'POST'
    }).then(function(response) {
        if(response.ok) {
            return response.json();
        } else {
            throw new Error();
        }
    }).then(function(json) {
        if (json["id"]) {
            console.log("OK:Fav");
        } else {
            console.warn("NG:Fav:"+json);
        }
    }).catch(function(error) {
        console.warn("NG:Fav:SERVER");
    });
}

function rt(id) {
    fetch("https://" + config.domain + "/api/v1/statuses/"+id+"/reblog", {
        headers: {'content-type': 'application/json', 'Authorization': 'Bearer '+config.token},
        method: 'POST'
    }).then(function(response) {
        if(response.ok) {
            return response.json();
        } else {
            throw new Error();
        }
    }).then(function(json) {
        if (json["id"]) {
            console.log("OK:RT");
        } else {
            console.warn("NG:RT:"+json);
        }
    }).catch(function(error) {
        console.warn("NG:RT:SERVER");
    });
}

function post(value, option = {}, visibility = "public", force) {
    var optiondata = {
        status: value,
        visibility: visibility
    };

    if (option.cw) {
        optiondata.spoiler_text = option.cw;
    }
    if (option.in_reply_to_id) {
        optiondata.in_reply_to_id = option.in_reply_to_id;
    }
    if (is_running || force) {
        fetch("https://" + config.domain + "/api/v1/statuses", {
            headers: {'content-type': 'application/json', 'Authorization': 'Bearer '+config.token},
            method: 'POST',
            body: JSON.stringify(optiondata)
        }).then(function(response) {
            if(response.ok) {
                return response.json();
            } else {
                throw new Error();
            }
        }).then(function(json) {
            if (json["id"]) {
                console.log("OK:POST");
            } else {
                console.warn("NG:POST:"+json);
            }
        }).catch(function(error) {
            console.warn("NG:POST:SERVER");
        });
    }
}

function horihori(depth, name, dead_mode, diggedDepth) {
    console.log(depth + " " + name + " " + dead_mode + " " + diggedDepth);
    let res = "", is_bedrock = false, i = 0, block = "";

    if (depth > 28 || diggedDepth > 28) is_bedrock = true;

    depth -= 3;
    diggedDepth -= 3;

    if (!depth) depth = diggedDepth;
    
    if (depth && diggedDepth >= depth) {
        res += "　​"+name+"\n";
        // res += ":minecraft_dirt:​:minecraft_dirt:​+"name"+​:minecraft_dirt:​:minecraft_dirt:\n";
    }
    if (diggedDepth != 0) {
        res += ":minecraft_dirt:​:minecraft_dirt:​　​:minecraft_dirt:​:minecraft_dirt:\n";
    } else {
        res += ":minecraft_dirt:​:minecraft_dirt:​:minecraft_dirt:​​:minecraft_dirt:​:minecraft_dirt:\n";
    }

    while (i <= depth) {
        if (i <= diggedDepth){
            res += ":minecraft_stone:​:minecraft_stone:​　​:minecraft_stone:​:minecraft_stone:\n";
        } else {
            res += ":minecraft_stone:​:minecraft_stone:​:minecraft_stone:​:minecraft_stone:​:minecraft_stone:\n";
        }
        i++;
    }

    if (dead_mode === "lava") block = "minecraft_lava";
    else if (dead_mode === "water") block = "minecraft_water";

    if (depth || depth > diggedDepth) {
        if (dead_mode === "lava") {
            res += ":"+block+":​:"+block+":​:"+block+":​:"+block+":​:"+block+":\n";
            res += ":"+block+":​:"+block+":​:"+block+":​:"+block+":​:"+block+":";
        } else if (dead_mode === "water") {
            res += ":"+block+":​:"+block+":​"+"　"+"​:"+block+":​:"+block+":\n";
            res += ":"+block+":​:"+block+":​:"+block+":​:"+block+":​:"+block+":";
        } else {
            res += ":minecraft_stone:​:minecraft_stone:​"+"　"+"​:minecraft_stone:​:minecraft_stone:\n";
            res += is_bedrock ? ":minecraft_bedrock:​:minecraft_bedrock:​:minecraft_bedrock:​:minecraft_bedrock:​:minecraft_bedrock:" : ":minecraft_stone:​:minecraft_stone:​:minecraft_stone:​:minecraft_stone:​:minecraft_stone:";
        }
    } else {
        if (dead_mode === "lava") {
            res += ":"+block+":​:"+block+":​:"+block+":​:"+block+":​:"+block+":\n";
            res += ":"+block+":​:"+block+":​:"+block+":​:"+block+":​:"+block+":";
        } else if (dead_mode === "water") {
            res += ":"+block+":​:"+block+":​:"+name +":​:"+block+":​:"+block+":\n";
            res += ":"+block+":​:"+block+":​:"+block+":​:"+block+":​:"+block+":";
        } else {
            res += ":minecraft_stone:​:minecraft_stone:​:"+name+":​:minecraft_stone:​:minecraft_stone:\n";
            res += is_bedrock ? ":minecraft_bedrock:​:minecraft_bedrock:​:minecraft_bedrock:​:minecraft_bedrock:​:minecraft_bedrock:" : ":minecraft_stone:​:minecraft_stone:​:minecraft_stone:​:minecraft_stone:​:minecraft_stone:";
        }
    }
    return res;
}

function change_running(mode) {
    if (mode === 1) {
        is_running = 1;
        console.log("OK:START");
    } else {
        is_running = 0;
        console.log("OK:STOP");
    }
}
