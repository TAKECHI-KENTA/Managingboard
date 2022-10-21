class CommentsController < ApplicationController
  def new
    @comment = Comment.new
    @tention = Tention.all
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
    params.require(:comment).permit(:tention_id, :description, :title)
  end 
end
