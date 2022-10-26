class BoardsController < ApplicationController
  def index
    #APIアクセストークンの取得(application_controllerより)
    get_token
    
    #会社名の取得　(application_controllerより)
    companies
    #銀行口座情報の取得
    #bank_walletables
    
  end
=begin
  private
    def bank_walletables
      @b_walletable_balance = nil     #walletable_balance: 登録残高
      @b_last_balance = nil           #last_balance: 同期残高
      company_id = @companies.first['id'] #事業所IDの取得
      uri = URI.parse("https://api.freee.co.jp/api/1/walletables?company_id=#{company_id}&with_balance=true&type=bank_account")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = { "Authorization": "Bearer #{session['token']}" }
      p session['token']
      req = Net::HTTP::Get.new(uri.path)
      req.initialize_http_header(headers)
      res = http.request(req)

      response = JSON.parse(res.body)     #データが空と表示される
      @b_walletables = response['walletables'] 
      #@b_walletable_balance = b_walletables.all.sum['walletable_balance']
      #@b_last_balance = b_walletables.all.sum['last_balance']
    end 
=end
end
