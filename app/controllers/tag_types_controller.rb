class TagTypesController < ApplicationController

  before_filter :check_authentication

  def index
    @tag_types = TagType.find(:all)
  end

  def create
    @tag_types = TagType.new(params[:tag_type])
    if @tag_types.save
      flash[:notice] = "Tag Type successfully created"
      redirect_to :tag_types
    else
      flash[:error] = @tag_types.errors.full_messages.to_s
      redirect_to :tag_types
    end
  end

  #TODO
  def destroy
    @tag_types = TagType.find(params[:id])
    if false #not @tags.activities.empty?
      flash[:error] = "Tag Type cannot be removed"
      redirect_to :tag_types
    else
      @tag_types.destroy
      flash[:notice] = "Tag Type removed"
      redirect_to :tag_types
    end
  end
  
end