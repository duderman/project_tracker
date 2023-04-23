# frozen_string_literal: true

RSpec.describe '/projects/:project_id/comments' do
  describe 'POST /projects/:project_id/comments' do
    subject(:request) { post "/projects/#{project_id}/comments", params: { comment: attributes } }

    let(:project) { create(:project) }
    let(:project_id) { project.id }

    before { allow(Turbo::StreamsChannel).to receive(:broadcast_prepend_later_to) }

    context 'with valid parameters' do
      let(:attributes) { { text: 'Yo' } }

      it 'redirects to project' do
        request
        expect(response).to redirect_to(project_path(project))
      end

      it 'creates a new Comment' do
        expect { request }.to change(Comment, :count).by(1)
        expect(Comment.last).to have_attributes(
          project:, data: { 'text' => 'Yo' }
        )
      end

      it 'schedules comment creation broadcast' do
        request
        expect(Turbo::StreamsChannel).to have_received(
          :broadcast_prepend_later_to
        ).with("channel_project_#{project_id}", target: 'project-history', partial: 'comments/comment',
                                                locals: { comment: instance_of(Comment) })
      end
    end

    context 'with invalid parameters' do
      let(:attributes) { { text: '' } }

      it 'renders project with errors' do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('projects/show')
      end

      it 'does not create a new Comment' do
        expect { request }.not_to change(Comment, :count)
      end

      it 'does not broadcast the project container' do
        request
        expect(Turbo::StreamsChannel).not_to have_received(:broadcast_prepend_later_to)
      end
    end

    context 'when the project does not exist' do
      let(:project_id) { 0 }
      let(:attributes) { {} }

      it 'renders a 404 response' do
        expect { request }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
