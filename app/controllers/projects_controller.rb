# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy next_transition]

  def index
    @projects = Project.all.order(created_at: :desc)
  end

  def show
    @comment = Comment.new(project: @project)
  end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        @project.broadcast_prepend_later_to :projects, target: 'projects-list', locals: { project: @project }
        format.turbo_stream
        format.html { redirect_to projects_path, notice: 'Project was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @project.update(project_params)
      BroadcastProjectUpdateJob.perform_later(@project)
      redirect_to projects_path, notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    @project.broadcast_remove_to :projects, target: project_container_id
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to projects_path, notice: 'Project was successfully destroyed.' }
    end
  end

  def next_transition
    TransitionProjectToNextStatus.call(@project)
    redirect_to current_project_path, notice: 'Project was successfully updated.'
  rescue TransitionProjectToNextStatus::NoMoreTransitionsError
    flash[:error] = 'No more transitions'
    redirect_to current_project_path
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name)
  end

  def project_container_id
    "#{helpers.dom_id(@project)}_container"
  end

  def current_project_path
    project_path(@project)
  end
end
