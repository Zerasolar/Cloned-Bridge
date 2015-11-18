class StoriesController < ApplicationController
  
  def index
    @stories = Story.all
    @posts = ActivityFeedItem.all.order('activity_feed_items.id DESC')
  end
  
  def show
    @story = Story.find(params["id"])
    # Loads view in views/stories/show
  end
  
  def new
    @new_story = Story.new
  end
  
  def create
    @new_story = current_user.stories.build(story_params)
    
    if @new_story.save
      title = @new_story.title
      content = @new_story.content
      link = story_path(@new_story)
      user_name = current_user.first_name
      Slack::Notifier::LinkFormatter.format(link)
      story_msg = {
        author_name: user_name,
        title: title,
        text: content,
        title_link: link,
        
      }
      Notifier.ping "New Story", attachments: [story_msg]
      redirect_to profile_path
    else
      render "new"
    end
  end
  
  def destroy
    @story = current_user.stories.find_by_id(params[:id])
    
    if @story
      @story.destroy
      redirect_to profile_path
    else
      redirect_to profile_path, alert: "Can't delete other people's stories."
    end
  end
  
  def edit
    @story = current_user.stories.find_by_id(params[:id])
    
    if !@story
      redirect_to profile_path, alert: "Can't find that story."
    end
  end
  
  def update
    @story = Story.find(params["id"])
    
    if @story.update_attributes(story_params)
      redirect_to profile_path
    else
      error_message = []
      @story.errors.full_messages.each do |msg|
        error_message.push(msg)
      end
      redirect_to profile_path, notice: "#{error_message.join(", ")}"
    end
  end
  
  private
  
  def set_stories
    @story = Story.find(params[:id])
  end
  
  def story_params
    params[:story].permit(:title, :content, :link)
  end
  
end