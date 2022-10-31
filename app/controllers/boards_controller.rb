class BoardsController < ApplicationController
  require 'uri'
  require 'net/http'

  def index
    # authorization_code
    if session['token'].blank?
      uri = URI('https://accounts.secure.freee.co.jp/public_api/token')
      res = Net::HTTP.post_form(uri, setting_params)
      p res.body
      response = JSON.parse(res.body)
      session['token'] = response['access_token']
    end
    companies
  end


  private

    def authorization_code
      uri = URI.parse('https://accounts.secure.freee.co.jp/public_api/authorize?response_type=code&client_id=17805fac1421de066eb60f6d44550fee83b3806cd14a6402090c817b42170079&redirect_uri=urn:ietf:wg:oauth:2.0:oob')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"
      headers = { "Content-Type" => "application/x-www-form-unlencoded " }
      req = Net::HTTP::Get.new(uri.path)
      req.initialize_http_header(headers)

      response = http.request(req)
      # TODO: 以下開発環境以外の環境が用意出来たら試す
      # redirect_to 'https://accounts.secure.freee.co.jp/public_api/authorize?client_id=17805fac1421de066eb60f6d44550fee83b3806cd14a6402090c817b42170079&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code'

      # redirect_to  response['Location']
      # @code = response.body['code'] # response body
    end

    def setting_params
      {
        "grant_type": "authorization_code",
        "client_id": "17805fac1421de066eb60f6d44550fee83b3806cd14a6402090c817b42170079",
        "client_secret": "fc4b0352c3f76c6bbec84af72dc7ffffc7dab501482dc8160d9140745f79c159",
        "code": "12a184ba40ebae0f12a54ac5650adb1aad11a72aa3f88292ba539ab3b262f87d",
        "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"
      }
    end

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

    def new
      @comment = Comment.new
    end

    def create
      @comment = current.user.comment.new(comment_params)

      if @comment.save
        redirect_to root_path, success: '投稿に成功しました'
      else
        flash.now[:danger] = "投稿に失敗しました"
      end
    end

    private
    def comment_params
      params.require(:comment).permit(:tention, :description, :title)
    end

end
