# frozen_string_literal: true

class BroadcastProjectUpdateJob < ApplicationJob
  include ActionView::RecordIdentifier
  include ProjectsHelper

  queue_as :broadcast

  def perform(project)
    @project = project

    project.broadcast_replace_to :projects, target: project_container_id, locals: { project: }
    project.broadcast_replace_to project_channel_id(project), target: project_header_id, locals: { project: },
                                                              partial: 'projects/project_header'
  end

  private

  attr_reader :project

  def project_container_id
    "#{project_dom_id}_container"
  end

  def project_header_id
    "#{project_dom_id}_header_container"
  end

  def project_dom_id
    dom_id(project)
  end
end
