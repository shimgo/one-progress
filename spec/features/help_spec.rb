require 'rails_helper'

feature 'ヘルプ' do
  scenario 'ヘルプリンクでヘルプを開いて、ヘルプリンクで閉じる', js: true do
    visit root_path
    expect(page).not_to have_content(
      'OneProgressは、ひとりで頑張れない人のための作業スペースです')
    find('#help-link', text: 'ヘルプ').click
    expect(page).to have_content(
      'OneProgressは、ひとりで頑張れない人のための作業スペースです')
    find('#help-link', text: 'ヘルプ').click
    expect(page).not_to have_content(
      'OneProgressは、ひとりで頑張れない人のための作業スペースです')
  end

  scenario 'ヘルプリンクでヘルプを開いて、矢印アイコンで閉じる', js: true do
    visit root_path
    expect(page).not_to have_content(
      'OneProgressは、ひとりで頑張れない人のための作業スペースです')
    find('#help-link', text: 'ヘルプ').click
    expect(page).to have_content(
      'OneProgressは、ひとりで頑張れない人のための作業スペースです')
    find('#close-help').click
    expect(page).not_to have_content(
      'OneProgressは、ひとりで頑張れない人のための作業スペースです')
  end
end
