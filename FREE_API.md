# FREE API

1. アクセストークンがなければ以下URIにアクセスする
https://accounts.secure.freee.co.jp/public_api/authorize?response_type=code&client_id=21cd64dfe5d15d867337f0b749fc6e75e938c02dbc6d8744b1d0f95bdc165f4e&redirect_uri=urn:ietf:wg:oauth:2.0:oob
2. ユーザがブラウザで許可をすればコールバックURLに設定しているアプリにレスポンスを返す
HTTP/1.1 302 found Location: {アプリのコールバックURL}?code={認可コード}  ({上記redirect_uri} {上記code})
3. アクセストークンをリクエストする
`curl -i -X POST \
  -H "Content-Type:application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \  
  -d "client_id=21cd64dfe5d15d867337f0b749fc6e75e938c02dbc6d8744b1d0f95bdc165f4e" \  
  -d "client_secret=a6234a8e382f4d91176f6fcd6328a34ef6091025f75c2a707d2d6b220ad44fd2" \  
  -d "code=b8346ddd2ef17a8833fb91dbb80ecad1e118c9832710a509861c2b574e7fb8c7" \  
  -d "redirect_uri=urn:ietf:wg:oauth:2.0:oob" \  
  'https://accounts.secure.freee.co.jp/public_api/token'`



4. companies取得
curl -X GET "https://api.freee.co.jp/api/1/companies" -H "accept: application/json" -H "Authorization: Bearer 359ca2ede0e1ab535dfde060b14fe7479505d8a6145c776020953eb8b39d23f4" -H "X-Api-Version: 2020-06-15"