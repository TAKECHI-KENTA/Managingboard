class CommentsController < ApplicationController
  def index
    @comments = Comment.all
  end
  
  def new
    @comment = Comment.new
    @tention = Tention.all
  end 
  
  def create
    @comment = current_user.comments.new(comment_params) #undefined method `comments' for nil:NilClass
    
    if @comment.save
      redirect_to root_path, success: '投稿に成功しました'
    else
      flash.now[:danger] = "投稿に失敗しました"
      render :new
    end
  end 
  
  private
  def comment_params
    params.require(:comment).permit(:tention_id, :description, :title)
  end 
end
