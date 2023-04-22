# frozen_string_literal: true

RSpec.shared_examples 'has jsonb accessor' do |accessor|
  it "has reader for '#{accessor}'" do
    model = described_class.new
    model.data = { accessor => 'value' }
    expect(model).to respond_to(accessor)
    expect(model.send(accessor)).to eq('value')
  end

  it "has writer for '#{accessor}'" do
    model = described_class.new
    expect(model).to respond_to("#{accessor}=")
    model.send("#{accessor}=", 'value')
    expect(model.data[accessor.to_s]).to eq('value')
  end
end
