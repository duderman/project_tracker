# frozen_string_literal: true

class BroadcastProjectUpdateJob < ApplicationJob
  queue_as :broadcast

  def perform(project)
    @project = project
    project.broadcast_replace_to :projects, target: project_container_id, locals: { project: }
    project.broadcast_replace_to :projects, target: project_header_id, locals: { project: },
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
    ActionView::RecordIdentifier.dom_id(project)
  end
end
