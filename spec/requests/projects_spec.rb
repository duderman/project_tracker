# frozen_string_literal: true

RSpec.describe '/projects' do
  describe 'GET /projects' do
    it 'renders a successful response' do
      project = create(:project)
      get '/projects'
      expect(response).to be_successful
      expect(response.body).to include(project.name)
    end
  end

  describe 'GET /projects/:id' do
    context 'when the project exists' do
      let(:project) { create(:project) }

      it 'renders a successful response' do
        get "/projects/#{project.id}"
        expect(response).to be_successful
        expect(response.body).to include(project.name)
        expect(response.body).to include('todo')
      end
    end

    context 'when the project does not exist' do
      it 'renders a 404 response' do
        expect { get '/projects/0' }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET /projects/new' do
    it 'renders form' do
      get '/projects/new'
      expect(response).to be_successful
      expect(assigns(:project)).to be_a_new(Project)
      expect(response).to render_template(:new)
      expect(response.body).to include('New Project')
    end
  end

  describe 'GET /projects/:id/edit' do
    let(:project) { create(:project) }

    it 'is successful' do
      get "/projects/#{project.id}/edit"
      expect(response).to be_successful
    end

    it 'renders form' do
      get "/projects/#{project.id}/edit"

      expect(assigns(:project)).to eq(project)
      expect(response).to render_template(:edit)
      expect(response.body).to include('Edit Project')
      expect(response.body).to include(project.name)
    end

    context 'when the project does not exist' do
      it 'renders a 404 response' do
        expect { get '/projects/0/edit' }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST /projects' do
    subject(:request) { post '/projects', params: { project: attributes } }

    before { allow(Turbo::StreamsChannel).to receive(:broadcast_prepend_later_to) }

    context 'with valid parameters' do
      let(:attributes) { attributes_for(:project) }

      it 'redirects to index' do
        request
        expect(response).to redirect_to(projects_path)
      end

      it 'creates a new Project' do
        expect { request }.to change(Project, :count).by(1)
      end

      it 'broadcasts the project container' do
        request
        expect(Turbo::StreamsChannel).to have_received(
          :broadcast_prepend_later_to
        ).with(:projects, target: 'projects-list', partial: 'projects/project',
                          locals: { project: instance_of(Project) })
      end
    end

    context 'with invalid parameters' do
      let(:attributes) { attributes_for(:project, name: '') }

      it 'renders form' do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end

      it 'does not create a new Project' do
        expect { request }.not_to change(Project, :count)
      end

      it 'does not broadcast the project container' do
        request
        expect(Turbo::StreamsChannel).not_to have_received(:broadcast_prepend_later_to)
      end
    end
  end

  describe 'PATCH /projects/:id' do
    subject(:request) { patch "/projects/#{project_id}", params: { project: attributes } }

    let(:project_id) { project.id }
    let(:project) { create(:project, name: 'Old name') }

    before { allow(Turbo::StreamsChannel).to receive(:broadcast_prepend_later_to) }

    context 'with valid parameters' do
      let(:attributes) { { name: 'New name' } }

      it 'redirects to index' do
        request
        expect(response).to redirect_to(projects_path)
      end

      it 'updates a project' do
        request
        expect(project.reload.name).to eq('New name')
      end

      it 'schedule a job to broadcast a project update' do
        expect { request }.to have_enqueued_job(BroadcastProjectUpdateJob).with(project)
      end
    end

    context 'with invalid parameters' do
      let(:attributes) { { name: '' } }

      it 'renders form' do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end

      it 'does not update project' do
        expect(project.reload.name).to eq('Old name')
      end

      it 'does not schedule a job to broadcast a project update' do
        expect { request }.not_to have_enqueued_job(BroadcastProjectUpdateJob)
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

  describe 'DELETE /projects/:id' do
    subject(:request) { delete "/projects/#{project_id}" }

    let(:project_id) { project.id }
    let!(:project) { create(:project) }

    before { allow(Turbo::StreamsChannel).to receive(:broadcast_remove_to) }

    it 'redirects to index' do
      request
      expect(response).to redirect_to(projects_path)
    end

    it 'destroys the requested project' do
      expect { request }.to change(Project, :count).by(-1)
    end

    it 'broadcasts the project remove' do
      request
      expect(Turbo::StreamsChannel).to have_received(
        :broadcast_remove_to
      ).with(:projects, target: "project_#{project.id}_container")
    end

    context 'when the project does not exist' do
      let(:project_id) { 0 }

      it 'renders a 404 response' do
        expect { request }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PUT /projects/:id/next_transition' do
    subject(:request) { put "/projects/#{project_id}/next_transition" }

    let(:project_id) { project.id }
    let(:project) { create(:project, status: 'todo') }

    it 'redirects to project' do
      request
      expect(response).to redirect_to(project_path(project))
    end

    it 'updates the project' do
      request
      expect(project.reload.status).to eq('in_progress')
    end

    it 'schedule a job to broadcast a project update' do
      expect { request }.to have_enqueued_job(BroadcastProjectUpdateJob).with(project)
    end

    context 'when project can be transitioned' do
      let(:project) { create(:project, status: 'completed') }

      it 'redirects to project with error' do
        request
        expect(response).to redirect_to(project_path(project))
        expect(flash[:error]).to eq('No more transitions')
      end

      it 'does not update the project' do
        request
        expect(project.reload.status).to eq('completed')
      end

      it 'does not schedule a job to broadcast a project update' do
        expect { request }.not_to have_enqueued_job(BroadcastProjectUpdateJob)
      end
    end

    context 'when the project does not exist' do
      let(:project_id) { 0 }

      it 'renders a 404 response' do
        expect { request }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
