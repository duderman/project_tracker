# frozen_string_literal: true

class StatusChange < ProjectHistoryEntry
  STATUS_CHANGE_SCHEMA = {
    'type' => 'object',
    'properties' => {
      'from' => { 'type' => 'string', 'minLength' => 1 },
      'to' => { 'type' => 'string', 'minLength' => 1 }
    },
    'required' => %w[from to]
  }.freeze

  validates :data, json: { message: ->(errors) { errors }, schema: STATUS_CHANGE_SCHEMA }

  jsonb_accessors :from, :to
end
