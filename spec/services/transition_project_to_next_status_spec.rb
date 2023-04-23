# frozen_string_literal: true

RSpec.describe TransitionProjectToNextStatus do
  let(:project) { create(:project) }
  let(:service) { described_class.new(project) }

  describe '#call' do
    subject(:call) { service.call }

    before do
      allow(Turbo::StreamsChannel).to receive(:broadcast_prepend_later_to)
      allow(BroadcastProjectUpdateJob).to receive(:perform_later)
    end

    it 'transitions project to the next status' do
      expect { call }.to change { project.reload.status }.from('todo').to('in_progress')
    end

    it 'creates a status change history entry' do
      expect { call }.to change(StatusChange, :count).by(1)
      expect(StatusChange.order(:created_at).last).to have_attributes(
        project:, data: { 'from' => 'todo', 'to' => 'in_progress' }
      )
    end

    it 'schedules broadcast of the status change creation' do
      call
      expect(Turbo::StreamsChannel).to have_received(
        :broadcast_prepend_later_to
      ).with("channel_project_#{project.id}", target: 'project-history', partial: 'status_changes/status_change',
                                              locals: { status_change: instance_of(StatusChange) })
    end

    it 'schedules update broadcast job' do
      call
      expect(BroadcastProjectUpdateJob).to have_received(:perform_later).with(project)
    end

    context "when project can't be transitioned" do
      let(:project) { build(:project, :completed) }

      it 'throws an exception' do
        expect { call }.to raise_error(Project::NoMoreTransitionsError)
      end
    end
  end
end
