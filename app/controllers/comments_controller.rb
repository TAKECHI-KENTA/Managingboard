require 'csv'

class CommentsController < ApplicationController
  def index
    @comments = Comment.preload(:tention).all
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_comments_csv(@comments)
      end 
    end
  end
  
  def download 
    @comments = Comment.all
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(@comments)
      end 
    end
  end
  
  def send_comments_csv(comments)
    csv_data = CSV.generate do |csv|
      header = %w(タイトル 機嫌 作成日時 メモ記載内容)
      csv << header
      comments.each do |comment|
        values = [comment.title, comment.tention.examination, comment.created_at.to_s(:datetime_jp), comment.description]
        csv << values
      end
    end
    send_data(csv_data, filename: "comments.csv")
  end 
  
  def new
    @comment = Comment.new
    @tention = Tention.all
    flash.now[:success] = "別ウィンドウでの表示がオススメです"
  end 
  
  def create
    @comment = current_user.comments.new(comment_params) 
    
    if @comment.save
      flash.now[:success] = "投稿に成功しました"
      # render :closed_and_reloaded, layout: false
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
