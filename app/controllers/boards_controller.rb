class BoardsController < ApplicationController
  #ライブラリの読み込み
  require 'uri'
  require 'net/http'
  require 'json'
  require 'date'
  require "active_support/time"
  
  def index
    #APIアクセストークンの取得(application_controllerより)
    get_token
    
    #会社名の取得　(application_controllerより)
    companies
    
    #未決済情報の取得
    unsettled_amounts_before_duedate
    unsettled_amounts_after_duedate
    
    #銀行/カード口座情報の取得
    bank_walletables
    card_walletables
    
  end

  private
    BASE_URL = "https://api.freee.co.jp/api/1/"
    ACCESS_TOKEN = "89afafdf56bb7cbecc55910284f0a37efbfa70aec275540e8077d6849f6c78cd"

    def unsettled_amounts_before_duedate
      @unsettled_in_bef_due = nil
      @unsettled_pay_bef_due = nil
      
      company_id = @companies.first['id']   #事業所IDの取得
      date = Date.today                     #本日の日付
      uri = URI.parse("#{BASE_URL}deals?company_id=#{company_id}&status=unsettled&start_due_date=#{date}") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } 
      p session['token']
      req = Net::HTTP::Get.new(uri.request_uri) #companiesではuri.pathでよかったがパラメーターを埋め込んでいるのでuri.request_uriになる
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      unsettled_deals_bef_due = response['deals']
      
      unsettled_deals_in_bef_due = unsettled_deals_bef_due.select {|value| value['type']=='income'}
      @unsettled_in_bef_due = unsettled_deals_in_bef_due.sum{ |hash| hash['amount'] }
      unsettled_deals_pay_bef_due = unsettled_deals_bef_due.select {|value| value['type']=='expense'}
      @unsettled_pay_bef_due = unsettled_deals_pay_bef_due.sum{ |hash| hash['amount'] }
    end
    
    def unsettled_amounts_after_duedate
      @unsettled_in = nil
      @unsettled_pay = nil
      @unsettled_in_aft_due = nil
      @unsettled_pay_aft_due = nil
      
      company_id = @companies.first['id']   #事業所IDの取得
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
      
      unsettled_deals_in = unsettled_deals.select {|value| value['type']=='income'}
      @unsettled_in = unsettled_deals_in.sum{ |hash| hash['amount'] }
      @unsettled_in_aft_due = @unsettled_in - @unsettled_in_bef_due
      unsettled_deals_pay = unsettled_deals.select {|value| value['type']=='expense'}
      @unsettled_pay = unsettled_deals_pay.sum{ |hash| hash['amount'] }
      @unsettled_pay_aft_due = @unsettled_pay - @unsettled_pay_bef_due
    end 
    
    def bank_walletables
      @b_walletable_balance = nil     #walletable_balance: 登録残高
      @b_last_balance = nil           #last_balance: 同期残高
      
      company_id = @companies.first['id'] #事業所IDの取得
      uri = URI.parse("#{BASE_URL}walletables?company_id=#{company_id}&with_balance=true&type=bank_account") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } #{session['token']}
      p session['token']
      req = Net::HTTP::Get.new(uri.request_uri) #companiesではuri.pathでよかったがパラメーターを埋め込んでいるのでuri.request_uriになる
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      b_walletables = response['walletables']
      
      @b_walletable_balance = b_walletables.sum{ |hash| hash['walletable_balance'] }
      @b_last_balance = b_walletables.sum{ |hash| hash['last_balance'] }
    end
    
    def card_walletables
      @c_walletable_balance = nil     #walletable_balance: 登録残高
      @c_last_balance = nil           #last_balance: 同期残高
      company_id = @companies.first['id'] #事業所IDの取得
      uri = URI.parse("#{BASE_URL}walletables?company_id=#{company_id}&with_balance=true&type=credit_card") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } #{session['token']}
      p session['token']
      req = Net::HTTP::Get.new(uri.request_uri) #companiesではuri.pathでよかったがパラメーターを埋め込んでいるのでuri.request_uriになる
      req.initialize_http_header(headers)
      res = http.request(req)
      response = JSON.parse(res.body) 
      c_walletables = response['walletables']
      
      @c_walletable_balance = c_walletables.sum{ |hash| hash['walletable_balance'] }
      @c_last_balance = c_walletables.sum{ |hash| hash['last_balance'] }
    end

end
