# frozen_string_literal: true

RSpec.describe Project do
  let(:project) { build(:project, status:) }
  let(:status) { 'todo' }

  describe '#next_transition' do
    subject { project.next_transition }

    context 'when the status is todo' do
      let(:status) { 'todo' }

      it { is_expected.to eq('start') }
    end

    context 'when the status is in_progress' do
      let(:status) { 'in_progress' }

      it { is_expected.to eq('finish') }
    end

    context 'when the status is completed' do
      let(:status) { 'completed' }

      it { is_expected.to be_nil }
    end
  end

  describe '#transition_to_next_state' do
    subject(:transition_to_next_state) { project.transition_to_next_state }

    context 'when the status is todo' do
      let(:status) { 'todo' }

      it 'transitions to in_progress' do
        expect { transition_to_next_state }.to change(project, :status).from('todo').to('in_progress')
      end
    end

    context 'when the status is in_progress' do
      let(:status) { 'in_progress' }

      it 'transitions to completed' do
        expect { transition_to_next_state }.to change(project, :status).from('in_progress').to('completed')
      end
    end

    context 'when the status is completed' do
      let(:status) { 'completed' }

      it { is_expected.to be_falsey }

      it 'does not transition' do
        expect { transition_to_next_state }.not_to change(project, :status)
      end
    end
  end

  describe '#may_transition?' do
    subject { project.may_transition? }

    context 'when the status is todo' do
      let(:status) { 'todo' }

      it { is_expected.to be_truthy }
    end

    context 'when the status is in_progress' do
      let(:status) { 'in_progress' }

      it { is_expected.to be_truthy }
    end

    context 'when the status is completed' do
      let(:status) { 'completed' }

      it { is_expected.to be_falsey }
    end
  end
end
