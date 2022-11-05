// import request from 'request';
// $(function() {
// var request = require("request");
// require('./dotenv').config();

//変数
// var token_url = "https://accounts.secure.freee.co.jp/public_api/token";
// // var redirect_uri = process.env.FREEE_REDIRECT_URI;  //envの使い方正しい？
// var redirect_uri = "urn:ietf:wg:oauth:2.0:oob";
// // var client_id = process.env.FREEE_CLIENT_ID;
// var client_id = "21cd64dfe5d15d867337f0b749fc6e75e938c02dbc6d8744b1d0f95bdc165f4e";
// // var client_secret = process.env.FREEE_CLIENT_SECRET;
// var client_secret = "a6234a8e382f4d91176f6fcd6328a34ef6091025f75c2a707d2d6b220ad44fd2";
// // var code = "認可コード";  //ここができてない//
// var code = "d6c2274bdab6450728124f2f3d8c9764da9ece8b8b09e5c35caa4697015ddda0";
// var access_token  = null;
// var refresh_token = null;
// var authorization_uri = "https://accounts.secure.freee.co.jp/public_api/authorize?client_id=21cd64dfe5d15d867337f0b749fc6e75e938c02dbc6d8744b1d0f95bdc165f4e&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=token"

// //アクセストークンを取得する。
// var options = {
//   method: 'POST',
//   url: token_url,
//   headers: {
//     'cache-control': 'no-cache',
//     'Content-Type': 'application/json'
//   },
//   form: {
//     grant_type: "authorization_code",
//     redirect_uri: redirect_uri,
//     client_id: client_id,
//     client_secret: client_secret,
//     code: code
//   },
//   json: true
// };

// const companies_uri = 'https://api.freee.co.jp/api/1/companies'
// const accessToken = 'e5c05fda2e0856dce76e2a4689645726f78376730950e541c5978c4ba23750d7'
// var _data = JSON.stringify({});
// $.ajax({
//   // type: "POST",
//   type: "GET",
//   url: companies_uri,
//   // url: authorization_uri,
//   headers: {
//     // 'cache-control': 'no-cache',
//     // 'Content-Type': 'application/json',
//     'Access-Control-Allow-Origin': 'https://api.freee.co.jp',
//     'Authorization': `Bearer ${accessToken}`,
//   },
//   data: _data
//   // {
//     // grant_type: "authorization_code",
//     // redirect_uri: redirect_uri,
//     // client_id: client_id,
//     // client_secret: client_secret,
//     // code: code
//   // }
// }).done(function( msg ) {
//   console.log(msg);
//   alert( "データ保存: " + msg );
// });

// // request(options, function (error, response, body) {
// //   if (error) throw new Error(error);
// //   console.log(body);
// //   //リクエストレスポンスからアクセストークンを取得する。
// //   var response = body;
// //   access_token = response.access_token;
// //   refresh_token = response.refresh_token;
// // });

// //リフレッシュトークンを用いてアクセストークンを取得する。
// var options = {
//   method: 'POST',
//   url: token_url,
//   headers: {
//     'cache-control': 'no-cache',
//     'Content-Type': 'application/x-www-form-urlencoded'
//   },
//   form: {
//     grant_type: "refresh_token",
//     redirect_uri: redirect_uri,
//     client_id: client_id,
//     client_secret: client_secret,
//     refresh_token: refresh_token
//   },
//   json: true
// };

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
