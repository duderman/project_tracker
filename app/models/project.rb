# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :history_entries, -> { order(created_at: :desc) },
           class_name: 'ProjectHistoryEntry',
           dependent: :destroy,
           inverse_of: :project

  has_many :comments # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :status_changes # rubocop:disable Rails/HasManyOrHasOneDependent

  validates :status, presence: true
  validates :name, presence: true

  enum status: { todo: 'todo', in_progress: 'in_progress', completed: 'completed' }

  include AASM

  aasm column: :status, enum: true do
    state :todo, initial: true
    state :in_progress
    state :completed

    event :start do
      transitions from: :todo, to: :in_progress
    end

    event :finish do
      transitions from: :in_progress, to: :completed
    end
  end

  def next_transition
    case status
    when 'todo' then 'start'
    when 'in_progress' then 'finish'
    end
  end

  def transition_to_next_state
    may_transition? && send("#{next_transition}!")
  end

  def may_transition?
    next_transition.present?
  end
end
