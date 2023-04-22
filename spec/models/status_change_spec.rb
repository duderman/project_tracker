# frozen_string_literal: true

RSpec.describe StatusChange do
  it 'validates the data' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    expect(build(:status_change, data: nil)).not_to be_valid
    expect(build(:status_change, data: {})).not_to be_valid
    expect(build(:status_change, data: { yo: 'yo' })).not_to be_valid
    expect(build(:status_change, data: { from: '' })).not_to be_valid
    expect(build(:status_change, data: { from: '', to: '' })).not_to be_valid
    expect(build(:status_change, data: { from: 'from', to: '' })).not_to be_valid
    expect(build(:status_change, data: { from: 'from', to: 'to' })).to be_valid
  end

  it_behaves_like 'has jsonb accessor', :from
  it_behaves_like 'has jsonb accessor', :to
end
