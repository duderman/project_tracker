# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }

    trait :completed do
      status { 'completed' }
    end
  end
end
