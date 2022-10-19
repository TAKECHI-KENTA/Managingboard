// const fetch = require('node-fetch');
// //const {connect, disconnect} = require('../../../../db/mongo');
// const {request} = require('./auth/gettoken'); //gettoken.jsの結果を渡す方法がこれでいいのか？

// exports.getCompanies = async () => {
//   //  await connect();
//   //  const tokens = await findToken(userId);
//   //  await disconnect();

//     const accessToken = request.access_token;  //gettoken.jsのrequestで手に入れたアクセストークンを代入する方法はこれでいいのか？
//     const response = await fetch('https://api.freee.co.jp/api/1/companies', {
//         headers: {'Authorization': `Bearer ${accessToken}`}
//     });
//     const responseJson = await response.json();
//     return responseJson.companies;
// };

// $(function() {
//     $("#Company_name").text("jQuery稼働テスト")
//   })

// JSON形式のファイルから特定の値だけを取り出し、htmlに渡す方法
