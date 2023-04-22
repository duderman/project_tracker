# frozen_string_literal: true

class ProjectHistoryEntry < ApplicationRecord
  belongs_to :project

  validates :type, presence: true
  validates :data, presence: true

  def self.jsonb_accessors(*args)
    args.each do |arg|
      define_method(arg) do
        data[arg.to_s]
      end

      define_method("#{arg}=") do |value|
        data[arg.to_s] = value
      end
    end
  end
end
