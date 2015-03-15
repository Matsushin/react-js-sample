class Api::CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy]

  def index
    @comments = Comment.all
    render json: @comments
  end

  def create
    Comment.create!(comment_params)
    @comments = Comment.all
    render json: @comments
  end

  def destroy
    @comment.destroy
    render json: { status: 'ok' }
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:author, :text)
  end
end
