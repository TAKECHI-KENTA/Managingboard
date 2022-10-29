class ApplicationController < ActionController::Base
  #ライブラリの読み込み
  require 'uri'
  require 'net/http'
  require 'json'
  require 'date'
  
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  
  # access_tokenの取得を最初に行う
  before_action :authorization_code
  before_action :get_token
  before_action :get_token_refresh
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end 
  
  def logged_in?
    !current_user.nil?
  end 
  
  def date
    Date.today
  end 

#APIを通したデータの取得
  #認可コードの取得 => private参照
  #アクセストークンの取得 (初回)
  def get_token
    if session['token'].blank?
      uri = URI('https://accounts.secure.freee.co.jp/public_api/token')
      res = Net::HTTP.post_form(uri, setting_params)
      response = JSON.parse(res.body)
      session['refresh_token'] = response['refresh_token']
      session['created_at'] = response['created_at']
      session['token'] = response['access_token']
    end
  end 
  #アクセストークンの取得(2回目以降)
  def get_token_refresh
    if Time.now > Time.at(session['created_at'], in:"+06:00") #freeeのアクセストークンは6時間で失効する
      uri = URI('https://accounts.secure.freee.co.jp/public_api/token')
      res = Net::HTTP.post_form(uri, setting_params_refresh)
      response = JSON.parse(res.body)
      session['refresh_token'] = response['refresh_token']
      session['created_at'] = response['created_at']
      session['token'] = response['access_token']
      p session['token']
      p session['refresh_token']
    end 
  end 
  
  #companyデータの取得。元々privateにあったがその理由は何か？またapplication_controllerに置くと全てのcontrollerからアクセス可能だが問題ないか？
  def companies
    @companies = nil
    uri = URI.parse('https://api.freee.co.jp/api/1/companies')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    headers = { "Authorization": "Bearer #{session['token']}" } 
    p session['token']
    req = Net::HTTP::Get.new(uri.path)
    req.initialize_http_header(headers)
    res = http.request(req)

    response = JSON.parse(res.body)
    @companies = response['companies']
  end

  private
    #認可コードの取得
    def authorization_code
      if session['token'].blank?
        uri = URI.parse(ENV['FREEE_REDIRECT_URI'])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme === "https"
        headers = { "Content-Type" => "application/x-www-form-unlencoded " }
        req = Net::HTTP::Get.new(uri.path)
        req.initialize_http_header(headers)
        response = http.request(req)
        @code = response.body['code']
      end
      # TODO: 以下開発環境以外の環境が用意出来たら試す => 一応上でできているはず
      # redirect_to 'https://accounts.secure.freee.co.jp/public_api/authorize?client_id=c3f9e03b19a97d825b9f38055a418ef44b2d6dd17eaac75c3d6b8f16d0031b0d&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code'

      # redirect_to  response['Location']
      # @code = response.body['code'] # response body
    end

    # access_token取得用パラメーター(1回目)
    def setting_params 
      {
        "grant_type": "authorization_code",
        "client_id": ENV['FREEE_CLIENT_ID'],
        "client_secret": ENV['FREEE_CLIENT_SECRET'],
        "code": authorization_code, 
        "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"
      }
    end
    # access_token取得用パラメーター(2回目以降)
    def setting_params_refresh
      {
        "grant_type": "refresh_token",
        "client_id": ENV['FREEE_CLIENT_ID'],
        "client_secret": ENV['FREEE_CLIENT_SECRET'],
        "refresh_token": session['refresh_token'],
        "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"
      }
    end 
end
