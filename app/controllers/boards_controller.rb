class BoardsController < ApplicationController
  #ライブラリの読み込み
  require 'uri'
  require 'net/http'
  require 'json'
  require 'date'
  require "active_support/time"
  
  def tsukimae(n)
    #表示用の月を定義
    date.months_ago(n).strftime("%m月")
  end
  
  def index
    #表示用の月を定義
    @kongetsu = date.strftime("%m月")
    @tsukimae_1 = tsukimae(1)
    @tsukimae_2 = tsukimae(2)
    @tsukimae_3 = tsukimae(3)
    
    #APIアクセストークンの取得(application_controllerより)
    get_token
    
    #会社名と事業所idの取得　(application_controllerより)
    companies
    
    #資金収支の取得
    #cash_inflow この処理がめちゃんこ重い
    #cash_outflow この処理がめちゃんこ重い
    
    #未決済残高の取得 (before=>期日前、after=>期日到来済みor期日:nil)
    unsettled_amounts_before_duedate
    unsettled_amounts_after_duedate
    
    #銀行/カード口座残高の取得
    bank_walletables
    card_walletables
    
  end

  private
    BASE_URL = "https://api.freee.co.jp/api/1/"
    ACCESS_TOKEN = "1098392c8badbfb6b671a70d89b9061bc829e4ca3577afcf141cb9f0d7599a26"

    def cash_flow(term, type)
      #APIでの収入取引取得
      company_id = @companies.first['id']    #事業所IDの取得
      uri = URI.parse("#{BASE_URL}wallet_txns?company_id=#{company_id}&walletable_type=bank_account&start_date=#{term}&end_date=#{term}&limit=100") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } 
      p session['token']
      req = Net::HTTP::Get.new(uri.request_uri) 
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      cash_deals = response['wallet_txns'] 
      
      #取得した取引を加工して変数に代入
      cash_type_deals = cash_deals.select {|value| value['type']=="#{type}"}
      cash_type_amount = cash_type_deals.sum{ |hash| hash['amount'] }
      p cash_type_amount
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
      company_id = @companies.first['id']   #事業所IDの取得
      date = Date.today                     #本日の日付
      uri = URI.parse("#{BASE_URL}deals?company_id=#{company_id}&status=unsettled&start_due_date=#{date}") #本日以降が決済期日の取引のみ取得
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } 
      p session['token']
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
      company_id = @companies.first['id']    #事業所IDの取得
      #date = Date.today                     #本日の日付
      uri = URI.parse("#{BASE_URL}deals?company_id=#{company_id}&status=unsettled") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } 
      p session['token']
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
      company_id = @companies.first['id'] #事業所IDの取得
      uri = URI.parse("#{BASE_URL}walletables?company_id=#{company_id}&with_balance=true&type=bank_account") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } #{session['token']}
      p session['token']
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
      company_id = @companies.first['id']    #事業所IDの取得
      uri = URI.parse("#{BASE_URL}walletables?company_id=#{company_id}&with_balance=true&type=credit_card") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } #{session['token']}
      p session['token']
      req = Net::HTTP::Get.new(uri.request_uri)
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      c_walletables = response['walletables']
      
      #取得した情報を加工して変数に代入
      @c_walletable_balance = c_walletables.sum{ |hash| hash['walletable_balance'] }
      @c_last_balance = c_walletables.sum{ |hash| hash['last_balance'] }
    end

end
