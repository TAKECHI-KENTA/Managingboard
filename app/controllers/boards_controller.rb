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
    @tsukimae_4 = tsukimae(4)
    @tsukimae_5 = tsukimae(5)
    
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
    
    #営業損益/収益/費用情報の取得
    pl_balances
    
  end

  private
    BASE_URL = "https://api.freee.co.jp/api/1/"
    ACCESS_TOKEN = ENV['FREEE_TEST_ACCESS_TOKEN'] #session['token']

    def cash_flow(term, type)
      #APIでの収入取引取得
      company_id = @companies.first['id']    #事業所IDの取得 paramsでもらう
      uri = URI.parse("#{BASE_URL}wallet_txns?company_id=#{company_id}&walletable_type=bank_account&start_date=#{term}&end_date=#{term}&entry_side=#{type}&limit=100") 
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
      cash_flow_amount = cash_deals.sum{ |hash| hash['amount'] }
      p cash_flow_amount
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

    def trial_balance(term)
      #APIでの収入取引取得
      company_id = @companies.first['id']                       #事業所IDの取得
      term_start = term.beginning_of_month.strftime("%Y-%m-%d") #開始日の指定
      term_end = term.end_of_month.strftime("%Y-%m-%d")         #終了日の指定
      uri = URI.parse("#{BASE_URL}reports/trial_pl?company_id=#{company_id}&start_date=#{term_start}&end_date=#{term_end}&account_item_display_type=group") 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = {"Authorization": "Bearer #{ACCESS_TOKEN}" } 
      p session['token']
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
      op_this_month = tb_this_month.select {|value| value['account_category_name']=='営業損益'}
      op_prev_1month = tb_prev_1month.select {|value| value['account_category_name']=='営業損益'}
      op_prev_2month = tb_prev_2month.select {|value| value['account_category_name']=='営業損益'}
      op_prev_3month = tb_prev_3month.select {|value| value['account_category_name']=='営業損益'}
      op_prev_4month = tb_prev_4month.select {|value| value['account_category_name']=='営業損益'}
      op_prev_5month = tb_prev_5month.select {|value| value['account_category_name']=='営業損益'}
      
      @op_transition_this_month = op_this_month[0]['closing_balance']
      @op_transition_prev_1month = op_prev_1month[0]['closing_balance']
      @op_transition_prev_2month = op_prev_2month[0]['closing_balance']
      @op_transition_prev_3month = op_prev_3month[0]['closing_balance']
      @op_transition_prev_4month = op_prev_4month[0]['closing_balance']
      @op_transition_prev_5month = op_prev_5month[0]['closing_balance']
      
      #営業損益---追加:タイトル表示する営業損益がマイナスの場合、div(1000)での強制切り捨て(マイナスが1大きくなる)を回避
      @op_transition_prev_1month_abs = @op_transition_prev_1month.abs
      @sign = "▲" if @op_transition_prev_1month < 0
      
      #収益(売上)---各月のbalancesから収益(rev)の金額('closing_balance')だけを抽出する
      rev_this_month = tb_this_month.select {|value| value['hierarchy_level']==1 && value['account_category_name']==('収入金額' || '売上高')}
      rev_prev_1month = tb_prev_1month.select {|value| value['hierarchy_level']==1 && value['account_category_name']==('収入金額' || '売上高')}
      rev_prev_2month = tb_prev_2month.select {|value| value['hierarchy_level']==1 && value['account_category_name']==('収入金額' || '売上高')}
      rev_prev_3month = tb_prev_3month.select {|value| value['hierarchy_level']==1 && value['account_category_name']==('収入金額' || '売上高')}
      rev_prev_4month = tb_prev_4month.select {|value| value['hierarchy_level']==1 && value['account_category_name']==('収入金額' || '売上高')}
      rev_prev_5month = tb_prev_5month.select {|value| value['hierarchy_level']==1 && value['account_category_name']==('収入金額' || '売上高')}
      
      @rev_transition_this_month = rev_this_month[0]['closing_balance']
      @rev_transition_prev_1month = rev_prev_1month[0]['closing_balance']
      @rev_transition_prev_2month = rev_prev_2month[0]['closing_balance']
      @rev_transition_prev_3month = rev_prev_3month[0]['closing_balance']
      @rev_transition_prev_4month = rev_prev_4month[0]['closing_balance']
      @rev_transition_prev_5month = rev_prev_5month[0]['closing_balance']
      
      #経費(売上原価除く)---
      #1ヶ月前のbalancesから経費の金額を抽出
      cost_prev_1month = tb_prev_1month.select {|value| value['hierarchy_level']==3 && value['account_category_name']==('経費' || '販売管理費')}
      #タイトル用の経費合計値を作りviewに渡す
      @cost_transition_prev_1month = cost_prev_1month.sum{ |hash| hash['closing_balance'] }
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
      p @cost_prev_1month_array_values
      p @cost_prev_1month_array_labels
    end
    
    
end
