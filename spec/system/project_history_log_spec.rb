# frozen_string_literal: true

RSpec.describe 'Project History Log' do
  let(:project) { create(:project) }
  let(:other_window) { open_new_window }

  before do
    visit "/projects/#{project.id}"
    within_window(other_window) { visit "/projects/#{project.id}" }
  end

  it 'allows comments creation' do
    fill_in 'comment[text]', with: 'My comment'
    click_on 'Add comment'

    expect(page).to have_content('My comment')
    within_window(other_window) { expect(page).to have_content('My comment') }
  end

  it 'logs status changes' do
    click_on 'start?'
    expect(page).to have_content('Status changed from TODO to IN PROGRESS')
    within_window(other_window) { expect(page).to have_content('Status changed from TODO to IN PROGRESS') }

    click_on 'finish?'
    expect(page).to have_content('Status changed from IN PROGRESS to COMPLETED')
    within_window(other_window) { expect(page).to have_content('Status changed from IN PROGRESS to COMPLETED') }
  end

  it 'sorts history by creation time' do
    create(:comment, project:, text: 'First comment', created_at: 3.days.ago)
    create(:status_change, project:, from: 'todo', to: 'in_progress', created_at: 2.days.ago)
    create(:comment, project:, text: 'Second comment', created_at: 1.day.ago)
    create(:status_change, project:, from: 'in_progress', to: 'completed')

    visit current_path

    expect(find(:css, '.list-item:nth-child(1)')).to have_content('Status changed from IN PROGRESS to COMPLETED')
    expect(find(:css, '.list-item:nth-child(2)')).to have_content('Second comment')
    expect(find(:css, '.list-item:nth-child(3)')).to have_content('Status changed from TODO to IN PROGRESS')
    expect(find(:css, '.list-item:nth-child(4)')).to have_content('First comment')
  end
end
