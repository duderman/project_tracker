# frozen_string_literal: true

RSpec.describe 'Projects' do
  it 'allows to create a project' do
    other_index_window = open_new_window

    visit '/'
    within_window(other_index_window) { visit '/' }

    click_on 'New Project'
    fill_in 'project_name', with: 'My project'
    click_on 'Create Project'

    expect(page).to have_content('My project')
    expect(page).to have_content('TODO')
    expect(page).not_to have_field('project_name')

    within_window(other_index_window) { expect(page).to have_content('My project') }
    within_window(other_index_window) { expect(page).not_to have_field('project_name') }
  end

  it 'allows cancelling creation' do
    visit '/'

    click_on 'New Project'
    click_on 'Cancel'

    expect(page).not_to have_field('project_name')
  end

  it 'allows editing project names' do
    project = create(:project, name: 'My project')

    other_index_window = open_new_window
    show_window = open_new_window

    visit '/'
    within_window(other_index_window) { visit '/' }
    within_window(show_window) { visit "/projects/#{project.id}" }

    expect(page).to have_content('My project')
    expect(page).to have_content('TODO')
    within_window(other_index_window) do
      expect(page).to have_content('My project')
      expect(page).to have_content('TODO')
    end
    within_window(show_window) do
      expect(page).to have_content('My project')
      expect(page).to have_content('TODO')
    end

    click_on 'Edit'
    fill_in 'project_name', with: 'My updated project'
    click_on 'Update Project'

    expect(page).to have_content('My updated project')
    expect(page).not_to have_field('project_name')

    within_window(other_index_window) { expect(page).to have_content('My updated project') }
    within_window(other_index_window) { expect(page).not_to have_field('project_name') }

    within_window(show_window) { expect(page).to have_content('My updated project') }

    expect(project.reload.name).to eq('My updated project')
  end

  it 'allows cancelling editing' do
    create(:project, name: 'My project')

    visit '/'

    click_on 'Edit'
    click_on 'Cancel'

    expect(page).not_to have_field('project_name')
  end

  it 'allows deleting projects' do
    create(:project, name: 'My project')
    other_index_window = open_new_window

    visit '/'
    within_window(other_index_window) { visit '/' }

    click_on 'Delete'

    expect(page).not_to have_content('My project')

    within_window(other_index_window) { expect(page).not_to have_content('My project') }
  end

  it 'allows changing project status' do
    create(:project, name: 'My project')

    index_window = open_new_window
    other_show_window = open_new_window

    within_window(index_window) { visit '/' }
    within_window(other_show_window) do
      visit '/'
      click_link 'My project'
    end

    visit '/'
    click_link 'My project'
    click_on 'start?'

    expect(page).to have_content('IN PROGRESS')
    within_window(index_window) { expect(page).to have_content('IN PROGRESS') }
    within_window(other_show_window) { expect(page).to have_content('IN PROGRESS') }

    click_on 'finish?'

    expect(page).to have_content('COMPLETED')
    within_window(index_window) { expect(page).to have_content('COMPLETED') }
    within_window(other_show_window) { expect(page).to have_content('COMPLETED') }
  end

  it 'validates project name presence' do
    create(:project, name: 'My project')

    visit '/'
    click_on 'New Project'
    click_on 'Create Project'

    expect(page).to have_content("Name can't be blank")

    click_link 'Cancel'
    click_on 'Edit'
    fill_in 'project_name', with: ''
    click_on 'Update Project'

    expect(page).to have_content("Name can't be blank")
  end
end
