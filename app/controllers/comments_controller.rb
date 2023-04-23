# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_project

  def create
    @comment = Comment.new(project: @project, data: comment_params)

    respond_to do |format|
      if @comment.save
        broadcast_comment
        format.turbo_stream
        format.html { redirect_to @project }
      else
        format.html { render 'projects/show', status: :unprocessable_entity }
      end
    end
  end

  private

  def broadcast_comment
    @comment.broadcast_prepend_later_to project_channel_id, target: 'project-history',
                                                            locals: { comment: @comment }
  end

  def project_channel_id
    helpers.project_channel_id(@project)
  end

  def comment_params
    params.require(:comment).permit(:text)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
