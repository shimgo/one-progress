require 'rails_helper'

feature 'タスク管理' do
  shared_examples '目的のタスクを探し出す', js: true do
    context '未着手タブのタスク数が1ページあたりの最大表示件数+1件の場合' do
      background do
        FactoryGirl.create(
          :task, owner: user, content: '最初に作ったタスク',
          status: :untouched, created_at: 10.minutes.ago
        )
        Settings.stopped_tasks_per_page.times do
          FactoryGirl.create(:task, owner: user)
        end
      end

      scenario 'タブを切り替えて未着手タスクを探し出す' do
        visit root_path
        find_link('未着手').click
        find_link('Next').click
        expect(page).to have_content('最初に作ったタスク')
      end
    end

    context '保留中タブのタスク数が1ページあたりの最大表示件数+1件の場合' do
      background do
        FactoryGirl.create(
          :task, owner: user, content: '最初に作ったタスク',
          status: :suspended, created_at: 10.minutes.ago
        )
        Settings.stopped_tasks_per_page.times do
          FactoryGirl.create(:task, owner: user, status: :suspended)
        end
      end

      scenario 'タブを切り替えて保留中タスクを探し出す' do
        visit root_path
        find_link('保留中').click
        find_link('Next').click
        expect(page).to have_content('最初に作ったタスク')
      end
    end

    context '完了タブのタスク数が1ページあたりの最大表示件数+1件の場合' do
      background do
        FactoryGirl.create(
          :task, owner: user, content: '最初に作ったタスク',
          status: :finished, created_at: 10.minutes.ago
        )
        Settings.stopped_tasks_per_page.times do
          FactoryGirl.create(:task, owner: user, status: :finished)
        end
      end

      scenario 'タブを切り替えて完了タスクを探し出す' do
        visit root_path
        find_link('完了').click
        find_link('Next').click
        expect(page).to have_content('最初に作ったタスク')
      end
    end
  end

  shared_examples 'タスクを操作する', js: true do
    scenario 'タスクを作成する' do
      visit root_path
      fill_in 'new-task-content', with: '参考書の1章を読み終える'
      select '20', from: 'new-task-target-time'
      click_button '作成'
      expect(page).to have_button '編集'
      expect(page).to have_link '開始'
      expect(page).to have_button '×'
      expect(page).to have_content '参考書の1章を読み終える'
      expect(page).to have_content '目標時間: 00:20'
      expect(page).to have_content '経過時間: 00:00'
      expect(page).to have_link '1', href: '#untouched'
      expect(page).to have_link '0', href: '#suspended'
      expect(page).to have_link '0', href: '#finished'
    end

    context 'タスクを作成している場合' do
      background do
        visit root_path
        fill_in 'new-task-content', with: '参考書の1章を読み終える'
        select '20', from: 'new-task-target-time'
        click_button '作成'
      end

      scenario 'タスクを開始＞完了' do
        visit root_path
        Timecop.freeze do
          find_link('開始').click
          started_at = Time.now
          target_time = started_at + 20.minutes
          expect(page).to have_content('タスクを開始しました')
          within('div#tasks-in-progress') do
            expect(page).to have_content '参考書の1章を読み終える'
            expect(page).to have_link '中断'
            expect(page).to have_link '完了'
            expect(page).to have_content "開始: #{started_at.strftime('%Y/%m/%d %H:%M')}"
            expect(page).to have_content "目標: #{target_time.strftime('%Y/%m/%d %H:%M')}"
          end
        end

        find_link('未着手').click
        within('.sidebar') do
          expect(page).not_to have_content '参考書の1章を読み終える'
        end
        expect(page).to have_link '0', href: '#untouched'
        expect(page).to have_link '0', href: '#suspended'
        expect(page).to have_link '0', href: '#finished'

        find_link('完了', class: 'btn-primary').click
        expect(page).to have_content('タスクを完了しました')
        within('div#tasks-in-progress') do
          expect(page).not_to have_content '参考書の1章を読み終える'
        end
        within('.sidebar') do
          find_link('完了').click
          expect(page).to have_content '参考書の1章を読み終える'
          expect(page).to have_content '目標時間: 00:20'
          expect(page).to have_content '経過時間: 00:00'
        end
        expect(page).to have_link '0', href: '#untouched'
        expect(page).to have_link '0', href: '#suspended'
        expect(page).to have_link '1', href: '#finished'
      end

      scenario 'タスクを編集＞開始' do
        visit root_path
        find_button('編集').click
        fill_in 'edit-task-content', with: '参考書の2章を読み終える'
        select '30', from: 'edit-task-target-time'
        find_button('更新').click
        expect(page).to have_content '参考書の2章を読み終える'
        expect(page).to have_content '目標時間: 00:30'
        expect(page).to have_content '経過時間: 00:00'

        Timecop.freeze do
          find_link('開始').click
          started_at = Time.now
          target_time = started_at + 30.minutes
          expect(page).to have_content('タスクを開始しました')
          within('div#tasks-in-progress') do
            expect(page).to have_content '参考書の2章を読み終える'
            expect(page).to have_content "開始: #{started_at.strftime('%Y/%m/%d %H:%M')}"
            expect(page).to have_content "目標: #{target_time.strftime('%Y/%m/%d %H:%M')}"
          end
        end
      end

      scenario 'タスクを開始＞中断＞再開' do
        elapsed_time = 10
        find_link('開始').click
        Timecop.travel(elapsed_time.minute.from_now)

        find_link('中断').click
        expect(page).to have_content('タスクを中断しました')
        within('div#tasks-in-progress') do
          expect(page).not_to have_content '参考書の1章を読み終える'
        end
        within('.sidebar') do
          find_link('保留中').click
          expect(page).to have_content '参考書の1章を読み終える'
          expect(page).to have_content '目標時間: 00:20'
          expect(page).to have_content "経過時間: 00:#{elapsed_time}"
        end
        expect(page).to have_link '0', href: '#untouched'
        expect(page).to have_link '1', href: '#suspended'
        expect(page).to have_link '0', href: '#finished'

        Timecop.freeze do
          started_at = Time.now
          target_time = started_at + elapsed_time.minute
          find_link('開始').click
          expect(page).to have_content('タスクを再開しました')
          within('div#tasks-in-progress') do
            expect(page).to have_content '参考書の1章を読み終える'
            expect(page).to have_content "開始: #{started_at.strftime('%Y/%m/%d %H:%M')}"
            expect(page).to have_content "目標: #{target_time.strftime('%Y/%m/%d %H:%M')}"
          end
        end

        within('.sidebar') do
          find_link('保留中').click
          expect(page).not_to have_content '参考書の1章を読み終える'
        end
        expect(page).to have_link '0', href: '#untouched'
        expect(page).to have_link '0', href: '#suspended'
        expect(page).to have_link '0', href: '#finished'
      end

      scenario 'タスクを削除' do
        find_button('×').click
        expect(page).to have_content '削除しますか？'
        find_link('削除').click
        within('.sidebar') do
          expect(page).not_to have_content '参考書の1章を読み終える'
        end
      end

      scenario 'タスクを削除＞キャンセル' do
        find_button('×').click
        expect(page).to have_content '削除しますか？'
        find_button('キャンセル').click
        within('.sidebar') do
          expect(page).to have_content '参考書の1章を読み終える'
        end
      end

      scenario 'タスクを完了＞削除' do
        find_link('開始').click
        find_link('完了', class: 'btn-primary').click
        within('.sidebar') do
          find_link('完了').click
        end
        find_button('×').click
        expect(page).to have_content '削除しますか？'
        find_link('削除').click
        within('.sidebar') do
          expect(page).not_to have_content '参考書の1章を読み終える'
        end
      end
    end

    scenario 'タスク作成で入力エラー発生後、正しく入力して登録' do
      expect(page).to have_link '0', href: '#untouched'
      find_button('作成').click
      expect(page).to have_content('内容を入力してください')

      fill_in 'new-task-content', with: '参考書の1章を読み終える'
      find_button('作成').click
      expect(page).to have_button '編集'
      expect(page).to have_link '開始'
      expect(page).to have_button '×'
      expect(page).to have_content '参考書の1章を読み終える'
      expect(page).to have_content '目標時間: 00:10'
      expect(page).to have_content '経過時間: 00:00'
      expect(page).to have_link '1', href: '#untouched'
      expect(page).to have_link '0', href: '#suspended'
      expect(page).to have_link '0', href: '#finished'
    end
  end

  context 'Twitterユーザの場合' do
    let(:twitter_user) {FactoryGirl.create(:twitter_user, :with_user)} 

    background do
      visit root_path
      login_as_twitter_user twitter_user
    end

    it_behaves_like 'タスクを操作する'

    it_behaves_like '目的のタスクを探し出す' do
      let(:user) {twitter_user.user} 
    end
  end

  context 'ゲストユーザの場合' do
    background do
      visit root_path
      login_as_guest_user 'guest'
    end

    it_behaves_like 'タスクを操作する'

    it_behaves_like '目的のタスクを探し出す' do
      let(:user) {User.find_by(username: 'guest')} 
    end
  end
end
