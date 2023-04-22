# frozen_string_literal: true

RSpec.describe BroadcastProjectUpdateJob do
  describe '#perform' do
    subject(:perform) { described_class.perform_now(project) }

    let(:project) { build(:project, id: uuid) }
    let(:uuid) { SecureRandom.uuid }

    before do
      allow(project).to receive(:broadcast_replace_to)
      perform
    end

    it 'broadcasts the project container' do
      expect(project).to have_received(:broadcast_replace_to).with(:projects, target: "project_#{uuid}_container",
                                                                              locals: { project: })
    end

    it 'broadcasts the project header' do
      expect(project).to have_received(:broadcast_replace_to).with(
        :projects, target: "project_#{uuid}_header_container",
                   locals: { project: },
                   partial: 'projects/project_header'
      )
    end
  end
end
