class ApplicationController < ActionController::Base
  #ライブラリの読み込み
  require 'uri'
  require 'net/http'
  require 'json'
  require 'date'
  
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end 
  
  def logged_in?
    !current_user.nil?
  end 
  
  def date
    Date.today
  end 
  
#APIデータの取得
  #認可コードの取得 => private参照
  #アクセストークンの取得
  def get_token
    if session['token'].blank?
      uri = URI('https://accounts.secure.freee.co.jp/public_api/token')
      res = Net::HTTP.post_form(uri, setting_params)
      p res.body
      response = JSON.parse(res.body)
      session['token'] = response['access_token']
      #refresh_token = response['refresh_token']
    end
=begin    
    if session['token'].blank?
      uri = URI('https://accounts.secure.freee.co.jp/public_api/token')
      res = Net::HTTP.post_form(uri, setting_params_refresh)
      p res.body
      response = JSON.parse(res.body)
      session['token'] = response['access_token']
      refresh_token = response['refresh_token']
    end
=end
  end 
  #companyデータの取得。元々privateにあったがその理由は何か？またapplication_controllerに置くと全てのcontrollerからアクセス可能だが問題ないか？
  def companies
    @companies = nil
    uri = URI.parse('https://api.freee.co.jp/api/1/companies')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    headers = { "Authorization": "Bearer 89894407d81d550bde682b882274fabeae70831616b227a51a1610e6dcb92e8e" } #{session['token']}
    p session['token']
    req = Net::HTTP::Get.new(uri.path)
    req.initialize_http_header(headers)
    res = http.request(req)

    response = JSON.parse(res.body)
    @companies = response['companies']
  end

  private
=begin
    #認可コードの取得
    def authorization_code
      uri = URI.parse(ENV['FREEE_REDIRECT_URI'])

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = { "Content-Type" => "application/x-www-form-unlencoded " }
      req = Net::HTTP::Get.new(uri.path)
      req.initialize_http_header(headers)

      response = http.request(req)
      @code = response.body['code']
      # TODO: 以下開発環境以外の環境が用意出来たら試す => 一応上でできているはず
      # redirect_to 'https://accounts.secure.freee.co.jp/public_api/authorize?client_id=c3f9e03b19a97d825b9f38055a418ef44b2d6dd17eaac75c3d6b8f16d0031b0d&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code'

      # redirect_to  response['Location']
      # @code = response.body['code'] # response body
    end
=end
    # access_tokenの取得に使うためのパラメーター
    def setting_params #takechi.kentaで登録したアプリ。
      {
        "grant_type": "authorization_code",
        "client_id": ENV['FREEE_CLIENT_ID'],
        "client_secret": ENV['FREEE_CLIENT_SECRET'],
        "code": ENV['FREEE_TEST_CODE'], #authorization_code, 
        "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"
      }
    end
=begin 
    def setting_params_refresh
      {
        "grant_type": "refresh_token",
        "client_id": ENV['FREEE_CLIENT_ID'],
        "client_secret": ENV['FREEE_CLIENT_SECRET'],
        "refresh_token": refresh_token,
        "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"
      }
    end 
=end
end
