class CommentsController < ApplicationController

  def create
    @comment = @post.comments.new(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      redirect_to @post, notice: "Your comment was successful"
    else
      error_message = []
      @comment.errors.full_messages.each do |msg|
        error_message.push(msg)
      end
      redirect_to @post, notice: "#{error_message.join(", ")}"
    end
    
    
  end
  
  def edit
    @comment = @post.comments.find_by_id(params[:id])
  end
  
  def update
    @comment = Comment.find(params["id"])
    
    if @comment.update_attributes(comment_params)
      redirect_to story_path(@comment.post_id)
    else
      render "edit"
    end
  end
  
  def destroy
    @comment = @post.comments.find_by_id(params[:id])
    
    if @comment
      @comment.destroy
      redirect_to story_path(@comment.post_id)
    else
      redirect_to story_path(@comment.post_id), alert: "Can't delete other people's comments."
    end
  end
   

  private

  def comment_params
    params[:comment].permit(:comment)
  end

end