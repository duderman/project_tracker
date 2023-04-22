# frozen_string_literal: true

class Comment < ProjectHistoryEntry
  COMMENT_SCHEMA = {
    'type' => 'object',
    'properties' => {
      'text' => { 'type' => 'string', 'minLength' => 1 }
    },
    'required' => ['text']
  }.freeze

  validates :data, json: { message: ->(errors) { errors }, schema: COMMENT_SCHEMA }

  jsonb_accessors :text
end
