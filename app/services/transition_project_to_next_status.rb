# frozen_string_literal: true

class TransitionProjectToNextStatus < ApplicationService
  NoMoreTransitionsError = Class.new(StandardError)

  include ActionView::RecordIdentifier
  include ProjectsHelper

  attr_reader :project, :initial_status, :status_change

  def initialize(project) # rubocop:disable Lint/MissingSuper
    @project = project
    @initial_status = project.status
  end

  def call
    validate!
    transition!
    schedule_log_broadcast
    schedule_update_broadcast
  end

  private

  def validate!
    raise NoMoreTransitionsError unless project.may_transition?
  end

  def transition!
    project.transaction do
      project.transition_to_next_status!
      log_status_change!
    end
  end

  def log_status_change!
    @status_change = StatusChange.create!(project:, data: { from: initial_status, to: project.status })
  end

  def schedule_log_broadcast
    status_change
      .broadcast_prepend_later_to(
        project_channel_id(project),
        target: 'project-history', locals: { status_change: }
      )
  end

  def schedule_update_broadcast
    BroadcastProjectUpdateJob.perform_later(project)
  end
end
