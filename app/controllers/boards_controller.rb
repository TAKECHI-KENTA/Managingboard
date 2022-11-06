class BoardsController < ApplicationController
  #ライブラリの読み込み
  require 'uri'
  require 'net/http'
  require 'json'
  require 'date'
  require "active_support/time"
  
  # access_tokenの取得を最初に行う
  before_action :authorization_code
  #before_action :setting_params 
  #before_action :get_token
  #before_action :setting_params_refresh
  before_action :get_token_refresh
  #before_action :company
  
  #日数表示に関する定義
  def date
    Date.today
  end 
  def tsukimae(n)
    #表示用の月を定義
    date.months_ago(n).strftime("%m月")
  end
  
  # ページの表示
  def index
    #表示用の月を定義
    @kongetsu = date.strftime("%m月")
    @tsukimae_1 = tsukimae(1)
    @tsukimae_2 = tsukimae(2)
    @tsukimae_3 = tsukimae(3)
    @tsukimae_4 = tsukimae(4)
    @tsukimae_5 = tsukimae(5)
   
    #認可コードの取得
    authorization_code
    #APIアクセストークンの取得
    #setting_params
    get_token
    #setting_params_refresh
    get_token_refresh
    
    #会社名と事業所idの取得
    company
    
    #資金収支の取得
    #cash_inflow #この処理がめちゃんこ重い
    #cash_outflow #この処理がめちゃんこ重い
    
    #未決済残高の取得 (before=>期日前、after=>期日到来済みor期日:nil)
    unsettled_amounts_before_duedate
    unsettled_amounts_after_duedate
    
    #銀行/カード口座残高の取得
    bank_walletables
    card_walletables
    
    #営業損益/収益/費用情報の取得
    pl_balances
  end
  
  private
    BASE_URL = "https://api.freee.co.jp/api/1/"
    
    #認可コードの取得
    def authorization_code
      if session['token'].blank?
        uri = URI.parse(ENV['FREEE_REDIRECT_URI'])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme === "https"
        headers = { "Content-Type" => "application/x-www-form-unlencoded " }
        req = Net::HTTP::Get.new(uri.path)
        req.initialize_http_header(headers)
        #response = http.request(req)
        #p response
        #@code = response.body['code']
        @code = params[:code]
        p @code
        p session['token']
        redirect_to "#{ENV['FREEE_REDIRECT_URI']}" if @code == nil
      end 
      # redirect_to 'https://accounts.secure.freee.co.jp/public_api/authorize?client_id=c3f9e03b19a97d825b9f38055a418ef44b2d6dd17eaac75c3d6b8f16d0031b0d&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code'
      # redirect_to  response['Location']
      # @code = response.body['code'] # response body
    end
    
    # access_token取得用パラメーター(初回)
      def setting_params 
        {
          "grant_type": "authorization_code",
          "client_id": ENV['FREEE_CLIENT_ID'],
          "client_secret": ENV['FREEE_CLIENT_SECRET'],
          "code": @code, 
          "redirect_uri": "https://safe-journey-01929.herokuapp.com/boards/index"
        }
      end
      
    #アクセストークンの取得 (初回)
    def get_token
      if session['token'].blank?
        uri = URI('https://accounts.secure.freee.co.jp/public_api/token')
        res = Net::HTTP.post_form(uri, setting_params)
        response = JSON.parse(res.body)
        session['refresh_token'] = response['refresh_token']
        session['created_at'] = response['created_at']
        session['token'] = response['access_token']
        p session['token']
        p session['refresh_token']
      end
    end
          
    # access_token取得用パラメーター(2回目以降)
      def setting_params_refresh
        {
          "grant_type": "refresh_token",
          "client_id": ENV['FREEE_CLIENT_ID'],
          "client_secret": ENV['FREEE_CLIENT_SECRET'],
          "refresh_token": session['refresh_token'],
          "redirect_uri": "https://safe-journey-01929.herokuapp.com/boards/index"
        }
      end 
        
    #アクセストークンの取得(2回目以降)
    def get_token_refresh
      if Time.now.to_i > (session['created_at'].to_i+21600) #freeeのアクセストークンは6時間で失効する
        uri = URI('https://accounts.secure.freee.co.jp/public_api/token')
        res = Net::HTTP.post_form(uri, setting_params_refresh)
        response = JSON.parse(res.body)
        session['refresh_token'] = response['refresh_token']
        session['created_at'] = response['created_at']
        session['token'] = response['access_token']
        p session['token']
        p session['refresh_token']
        p setting_params_refresh
        authorization_code if session['token'].blank?
      end 
    end 
    
    #companyデータの取得
    def company
      #ひもづく会社のデータを全てGETする
      uri = URI.parse('https://api.freee.co.jp/api/1/companies')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = { "Authorization": "Bearer #{session['token']}" } 
      req = Net::HTTP::Get.new(uri.path)
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body)
      @companies = response['companies']
      #会社選択用のハッシュを作る
      @companies_hash = {}
      @companies.each do |keys|
        @companies_hash.store(keys["display_name"],keys["id"])
      end 
      #会社
      @company = @companies.first
      # 2回目以降は選択されたcompanies
      @company = @companies.find{ |x| x["id"] == params[:id].to_i } unless params[:id].blank?   #最初の会社表示はcompaniesの先頭にあるもの
    end
    
    # KPIカード用のデータ取得  
    def cash_flow(term, type)
      #APIでの収入取引取得
      company_id = @company['id']    #事業所IDの取得 
      uri = URI.parse("#{BASE_URL}wallet_txns?company_id=#{company_id}&walletable_type=bank_account&start_date=#{term}&end_date=#{term}&entry_side=#{type}&limit=100") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{session['token']}" } 
      req = Net::HTTP::Get.new(uri.request_uri) 
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      cash_deals = response['wallet_txns'] 
      cash_flow_amount = cash_deals.sum{ |hash| hash['amount'] } #取得した取引から金額を合計する
    end 
  
    def cash_inflow
      @cash_inflow_this_month = 0
      for term in date.beginning_of_month..date.end_of_month
        @cash_inflow_this_month += cash_flow(term.strftime("%Y-%m-%d"), "income")
      end
      
      @cash_inflow_prev_month = 0
      for term in date.beginning_of_month.months_ago(1)...date.beginning_of_month
        @cash_inflow_prev_month += cash_flow(term.strftime("%Y-%m-%d"), "income")
      end
      
      @cash_inflow_2prev_month = 0
      for term in date.beginning_of_month.months_ago(2)...date.beginning_of_month.months_ago(1)
        @cash_inflow_2prev_month += cash_flow(term.strftime("%Y-%m-%d"), "income")
      end
      
      @cash_inflow_3prev_month = 0
      for term in date.beginning_of_month.months_ago(3)...date.beginning_of_month.months_ago(2)
        @cash_inflow_3prev_month += cash_flow(term.strftime("%Y-%m-%d"), "income")
      end
    end
    
    def cash_outflow
      @cash_outflow_this_month = 0
      for term in date.beginning_of_month..date.end_of_month
        @cash_outflow_this_month += cash_flow(term.strftime("%Y-%m-%d"), "expense")
      end
      
      @cash_outflow_prev_month = 0
      for term in date.beginning_of_month.months_ago(1)...date.beginning_of_month
        @cash_outflow_prev_month += cash_flow(term.strftime("%Y-%m-%d"), "expense")
      end
      
      @cash_outflow_2prev_month = 0
      for term in date.beginning_of_month.months_ago(2)...date.beginning_of_month.months_ago(1)
        @cash_outflow_2prev_month += cash_flow(term.strftime("%Y-%m-%d"), "expense")
      end
      
      @cash_outflow_3prev_month = 0
      for term in date.beginning_of_month.months_ago(3)...date.beginning_of_month.months_ago(2)
        @cash_outflow_3prev_month += cash_flow(term.strftime("%Y-%m-%d"), "expense")
      end
    end
    
    def unsettled_amounts_before_duedate
      #変数定義
      @unsettled_in_bef_due = nil
      @unsettled_pay_bef_due = nil
      
      #APIでの取引取得
      p @company
      company_id = @company['id']   #事業所IDの取得
      date = Date.today                     #本日の日付
      uri = URI.parse("#{BASE_URL}deals?company_id=#{company_id}&status=unsettled&start_due_date=#{date}") #本日以降が決済期日の取引のみ取得
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{session['token']}" } 
      req = Net::HTTP::Get.new(uri.request_uri) #companiesではuri.pathでよかったがパラメーターを埋め込んでいるのでuri.request_uriになる
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      unsettled_deals_bef_due = response['deals']
      
      #取得した取引を加工して変数に代入
      unsettled_deals_in_bef_due = unsettled_deals_bef_due.select {|value| value['type']=='income'}
      @unsettled_in_bef_due = unsettled_deals_in_bef_due.sum{ |hash| hash['amount'] }
      unsettled_deals_pay_bef_due = unsettled_deals_bef_due.select {|value| value['type']=='expense'}
      @unsettled_pay_bef_due = unsettled_deals_pay_bef_due.sum{ |hash| hash['amount'] }
    end
    
    def unsettled_amounts_after_duedate
      #変数の定義
      @unsettled_in = nil
      @unsettled_pay = nil
      @unsettled_in_aft_due = nil
      @unsettled_pay_aft_due = nil
      
      #APIでの取引取得
      company_id = @company['id']    #事業所IDの取得
      #date = Date.today                     #本日の日付
      uri = URI.parse("#{BASE_URL}deals?company_id=#{company_id}&status=unsettled") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{session['token']}" } 
      req = Net::HTTP::Get.new(uri.request_uri) 
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      unsettled_deals = response['deals']
      
      #取得した取引を加工して変数に代入
      unsettled_deals_in = unsettled_deals.select {|value| value['type']=='income'}
      @unsettled_in = unsettled_deals_in.sum{ |hash| hash['amount'] }
      @unsettled_in_aft_due = @unsettled_in - @unsettled_in_bef_due
      unsettled_deals_pay = unsettled_deals.select {|value| value['type']=='expense'}
      @unsettled_pay = unsettled_deals_pay.sum{ |hash| hash['amount'] }
      @unsettled_pay_aft_due = @unsettled_pay - @unsettled_pay_bef_due
    end 
    
    def bank_walletables
      #変数の定義
      @b_walletable_balance = nil     #walletable_balance: 登録残高
      @b_last_balance = nil           #last_balance: 同期残高
      
      #APIによる口座情報の取得
      company_id = @company['id'] #事業所IDの取得
      uri = URI.parse("#{BASE_URL}walletables?company_id=#{company_id}&with_balance=true&type=bank_account") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{session['token']}" } #{session['token']}
      req = Net::HTTP::Get.new(uri.request_uri) 
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      b_walletables = response['walletables']
      
      #取得した情報を加工して変数に代入
      @b_walletable_balance = b_walletables.sum{ |hash| hash['walletable_balance'] }
      @b_last_balance = b_walletables.sum{ |hash| hash['last_balance'] }
    end
    
    def card_walletables
      #変数の定義
      @c_walletable_balance = nil            #walletable_balance: 登録残高
      @c_last_balance = nil                  #last_balance: 同期残高
      
      #APIによる口座情報の取得
      company_id = @company['id']    #事業所IDの取得
      uri = URI.parse("#{BASE_URL}walletables?company_id=#{company_id}&with_balance=true&type=credit_card") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{session['token']}" } #{session['token']}
      req = Net::HTTP::Get.new(uri.request_uri)
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      c_walletables = response['walletables']
      
      #取得した情報を加工して変数に代入
      @c_walletable_balance = c_walletables.sum{ |hash| hash['walletable_balance'] }
      @c_last_balance = c_walletables.sum{ |hash| hash['last_balance'] }
    end
  
    def trial_balance(term)
      #APIでの収入取引取得
      company_id = @company['id']                               #事業所IDの取得
      term_start = term.beginning_of_month.strftime("%Y-%m-%d") #開始日の指定
      term_end = term.end_of_month.strftime("%Y-%m-%d")         #終了日の指定
      uri = URI.parse("#{BASE_URL}reports/trial_pl?company_id=#{company_id}&start_date=#{term_start}&end_date=#{term_end}&account_item_display_type=group") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{session['token']}" } 
      req = Net::HTTP::Get.new(uri.request_uri) 
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      trial_balances = response['trial_pl']['balances'] 
      p trial_balances
    end 
  
    def pl_balances
      #trial_balance(term)の期間指定で特定期間のbalances(hash)を取得
      tb_this_month = trial_balance(date)
      tb_prev_1month = trial_balance(date.months_ago(1))
      tb_prev_2month = trial_balance(date.months_ago(2))
      tb_prev_3month = trial_balance(date.months_ago(3))
      tb_prev_4month = trial_balance(date.months_ago(4))
      tb_prev_5month = trial_balance(date.months_ago(5))
      
      #営業損益---各月のbalancesから営業損益(op)の金額('closing_balance')だけを抽出する
      op_this_month = tb_this_month.select {|value| value['account_category_name'].include?('営業損益')}
      op_prev_1month = tb_prev_1month.select {|value| value['account_category_name'].include?('営業損益')}
      op_prev_2month = tb_prev_2month.select {|value| value['account_category_name'].include?('営業損益')}
      op_prev_3month = tb_prev_3month.select {|value| value['account_category_name'].include?('営業損益')}
      op_prev_4month = tb_prev_4month.select {|value| value['account_category_name'].include?('営業損益')}
      op_prev_5month = tb_prev_5month.select {|value| value['account_category_name'].include?('営業損益')}
      
      @op_transition_this_month = op_this_month[0]['credit_amount'] - op_this_month[0]['debit_amount']
      @op_transition_prev_1month = op_prev_1month[0]['credit_amount'] - op_prev_1month[0]['debit_amount']
      @op_transition_prev_2month = op_prev_2month[0]['credit_amount'] - op_prev_2month[0]['debit_amount']
      @op_transition_prev_3month = op_prev_3month[0]['credit_amount'] - op_prev_3month[0]['debit_amount']
      @op_transition_prev_4month = op_prev_4month[0]['credit_amount'] - op_prev_4month[0]['debit_amount']
      @op_transition_prev_5month = op_prev_5month[0]['credit_amount'] - op_prev_5month[0]['debit_amount']
      
      #営業損益---追加:タイトル表示する営業損益がマイナスの場合、div(1000)での強制切り捨て(マイナスが1大きくなる)を回避
      @op_transition_prev_1month_abs = @op_transition_prev_1month.abs
      @sign = "▲" if @op_transition_prev_1month < 0
      
      #収益(売上)---各月のbalancesから収益(rev)の金額('closing_balance')だけを抽出する
      rev_this_month = tb_this_month.select {|value| value['hierarchy_level']==1 && (value['account_category_name'] == '収入金額' || value['account_category_name'] == '売上高')}
      rev_prev_1month = tb_prev_1month.select {|value| value['hierarchy_level']==1 && (value['account_category_name'] == '収入金額' || value['account_category_name'] == '売上高')}
      rev_prev_2month = tb_prev_2month.select {|value| value['hierarchy_level']==1 && (value['account_category_name'] == '収入金額' || value['account_category_name'] == '売上高')}
      rev_prev_3month = tb_prev_3month.select {|value| value['hierarchy_level']==1 && (value['account_category_name'] == '収入金額' || value['account_category_name'] == '売上高')}
      rev_prev_4month = tb_prev_4month.select {|value| value['hierarchy_level']==1 && (value['account_category_name'] == '収入金額' || value['account_category_name'] == '売上高')}
      rev_prev_5month = tb_prev_5month.select {|value| value['hierarchy_level']==1 && (value['account_category_name'] == '収入金額' || value['account_category_name'] == '売上高')}
      
      @rev_transition_this_month = rev_this_month[0]['credit_amount'] - rev_this_month[0]['debit_amount']
      @rev_transition_prev_1month = rev_prev_1month[0]['credit_amount'] - rev_prev_1month[0]['debit_amount']
      @rev_transition_prev_2month = rev_prev_2month[0]['credit_amount'] - rev_prev_2month[0]['debit_amount']
      @rev_transition_prev_3month = rev_prev_3month[0]['credit_amount'] - rev_prev_3month[0]['debit_amount']
      @rev_transition_prev_4month = rev_prev_4month[0]['credit_amount'] - rev_prev_4month[0]['debit_amount']
      @rev_transition_prev_5month = rev_prev_5month[0]['credit_amount'] - rev_prev_5month[0]['debit_amount']
      
      #経費(売上原価除く)---
      #1ヶ月前のbalancesから経費の金額を抽出
      cost_prev_1month = tb_prev_1month.select {|value| value['hierarchy_level']==3 && (value['account_category_name'] == '経費' || value['account_category_name'] == '販売管理費')}
      #タイトル用の経費合計値を作りviewに渡す
      @cost_transition_prev_1month = cost_prev_1month.sum{ |hash| hash['debit_amount'] } - cost_prev_1month.sum{ |hash| hash['credit_amount'] }
      #グラフ用の配列データを作る
      cost_value_ary = Array.new
      cost_label_ary = Array.new
      cost_prev_1month.each do |keys|
        cost_value_ary.push keys['closing_balance']
        cost_label_ary.push keys['account_group_name']
      end 
      #配列をviewに引き渡す - 金額
      @cost_prev_1month_array_values = cost_value_ary
      #配列をviewに引き渡す - 経費科目 ※Plotyの仕様上、railsの配列の"xx"を読み込む時に" "を飛ばして、xxだけ読み込んでしまうので'xxx'になるよう補正 
      #cost_label_ary_2 = Array.new
      #cost_label_ary.each do |labels|
      #  cost_label_ary_2.push labels.to_sym                         
      #end
      @cost_prev_1month_array_labels = cost_label_ary
    end
end
