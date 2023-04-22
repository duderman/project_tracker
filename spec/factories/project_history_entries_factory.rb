# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    project
    type { 'Comment' }
    data { { text: Faker::Lorem.sentence } }
  end

  factory :status_change do
    project
    type { 'StatusChange' }
    data { { from: 'todo', to: 'in_progress' } }
  end
end
