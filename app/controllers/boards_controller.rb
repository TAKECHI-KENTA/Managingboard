class BoardsController < ApplicationController
  def index
    @comment = Comment.new
    @tention = Tention.all
  end
  
end
