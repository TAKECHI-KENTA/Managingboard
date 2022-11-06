class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: user_params[:email])
    if user && user.authenticate(user_params[:password])
      log_in user
      redirect_to boards_index_path
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new
    end 
  end
  
  def destroy
    log_out
    redirect_to login_path, info: 'ログアウトしました'
  end 
  
  private
  def user_params
    params.require(:session).permit(:email, :password)
  end
  def log_in(user)
    session[:user_id] = user.id
  end 
  
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end 
end
