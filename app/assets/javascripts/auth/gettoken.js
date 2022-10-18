var request = require("request");
require('./dotenv').config();

//変数
var token_url = "https://accounts.secure.freee.co.jp/public_api/token";
var redirect_uri = process.env.FREEE_REDIRECT_URI;  //envの使い方正しい？
var client_id = process.env.FREEE_CLIENT_ID;
var client_secret = process.env.FREEE_CLIENT_SECRET;
var code = "取得した認可コード";  //ここができてない//
var access_token = null;
var refresh_token = null;

//アクセストークンを取得する。
var options = {
  method: 'POST',
  url: token_url,
  headers: {
    'cache-control': 'no-cache',
    'Content-Type': 'application/json'
  },
  form: {
    grant_type: "authorization_code",
    redirect_uri: redirect_uri,
    client_id: client_id,
    client_secret: client_secret,
    code: code
  },
  json: true
};

request(options, function (error, response, body) {
  if (error) throw new Error(error);
  console.log(body);
  //リクエストレスポンスからアクセストークンを取得する。
  var response = body;
  access_token = response.access_token;
  refresh_token = response.refresh_token;
});

//リフレッシュトークンを用いてアクセストークンを取得する。
var options = {
  method: 'POST',
  url: token_url,
  headers: {
    'cache-control': 'no-cache',
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  form: {
    grant_type: "refresh_token",
    redirect_uri: redirect_uri,
    client_id: client_id,
    client_secret: client_secret,
    refresh_token: refresh_token
  },
  json: true
};

request(options, function (error, response, body) {
  if (error) throw new Error(error);
  //リクエストレスポンスからアクセストークンを取得する。
  var response = body;
  access_token = response.access_token;
  refresh_token = response.refresh_token;
});

// 以下、メンタリング中に記載//
export const getToken = request(options, function (error, response, body) {
  if (error) throw new Error(error);
  console.log(body);
  //リクエストレスポンスからアクセストークンを取得する。
  var response = body;
  access_token = response.access_token;
  refresh_token = response.refresh_token;
  return access_token 
});

export const refresToken = request(options, function (error, response, body) {
  if (error) throw new Error(error);
  //リクエストレスポンスからアクセストークンを取得する。
  var response = body;
  access_token = response.access_token;
  refresh_token = response.refresh_token;
  return access_token
});

$(function() {
    $("#Company_name").text("xxx")
  })