# frozen_string_literal: true

RSpec.describe Comment do
  it 'validates the data' do
    expect(build(:comment, data: nil)).not_to be_valid
    expect(build(:comment, data: {})).not_to be_valid
    expect(build(:comment, data: { yo: 'yo' })).not_to be_valid
    expect(build(:comment, data: { text: '' })).not_to be_valid
    expect(build(:comment, data: { text: 'comment' })).to be_valid
  end

  it_behaves_like 'has jsonb accessor', :text
end
