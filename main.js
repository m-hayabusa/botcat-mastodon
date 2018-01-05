let is_running = 1;
let eti = 0;
let config = require('./config');
let fetch = require('node-fetch');

let WebSocketClient = require('websocket').client;
let client = new WebSocketClient();

client.on('connectFailed', function(error) {
    console.log('Connect Error: ' + error.toString());
});

client.on('connect', function(connection) {
    console.log('WebSocket Client Connected');
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
                            console.log(text);

                             //メイン部分
                             if (text.match(regStart)) {
                                fav(json['id']);
                             }
                        } else {
                            if (acct === config.admin) {
                                if (text.match(/!start/i) || text.match(/(猫Bot|ねこぼっと)(起動|おきて|起きて)/i)) {
                                    post("起動したにゃ");
                                    change_running(1);
                                }
                            }
                        }
                    }
                }
            }
        } catch (e) {
            post("エラーが発生したです\n止まるです");
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

function change_running(mode) {
    if (mode === 1) {
        is_running = 1;
        console.log("OK:START");
    } else {
        is_running = 0;
        console.log("OK:STOP");
    }
}
