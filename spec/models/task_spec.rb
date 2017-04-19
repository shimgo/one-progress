require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user) do
    FactoryGirl.create(:user)
  end

  describe 'validation' do
    it 'contentとtarget_timeが空でなければ有効であること' do
      task = Task.new(content: 'タスク内容', target_time: Time.at(0))
      expect(task).to be_valid
    end

    describe 'content' do
      it '空であれば無効であること' do
        task = Task.new(content: nil, target_time: Time.at(0))
        task.valid?
        expect(task.errors[:content]).to include("を入力してください")
      end

      it '長さが200文字以内であれば有効であること' do
        task = Task.new(content: 'あ' * 200, target_time: Time.at(0))
        expect(task).to be_valid
      end

      it '長さが200文字超であれば無効であること' do
        task = Task.new(content: 'あ' * 201, target_time: Time.at(0))
        task.valid?
        expect(task.errors[:content]).to include("は200文字以内で入力してください")
      end
    end

    describe 'target_time' do
      it '空であれば無効であること' do
        task = Task.new(target_time: nil)
        task.valid?
        expect(task.errors[:target_time]).to include("を入力してください")
      end

      it '60分の場合、有効であること' do
        task = Task.new(content: 'あ', target_time: Time.at(3600))
        expect(task).to be_valid
      end

      it '60分を超える場合、無効であること' do
        task = Task.new(target_time: Time.at(3601))
        task.valid?
        expect(task.errors[:target_time]).to include("は60分以内にしてください")
      end
    end
  end

  describe 'scope' do
    describe 'in_progress' do
      before do
        @untouched_task = Task.create(status: :untouched, content: 'test', target_time: Time.at(600))
        @started_task   = Task.create(status: :started,   content: 'test', target_time: Time.at(600))
        @suspended_task = Task.create(status: :suspended, content: 'test', target_time: Time.at(600))
        @resumed_task   = Task.create(status: :resumed,   content: 'test', target_time: Time.at(600))
        @finished_task  = Task.create(status: :finished,  content: 'test', target_time: Time.at(600))
      end

      it 'statusがstartedとresumedのタスクが含まれていること' do
        expect(Task.in_progress).to include @started_task, @resumed_task
      end

      it 'statusがstartedまたはresumed以外のタスクは含まないこと' do
        expect(Task.in_progress).not_to include @untouched_task, @suspended_task, @finished_task
      end
    end
  end

  describe '#start' do
    let(:task) do
      task = Task.new(
        content: '内容', 
        status: :untouched,
        target_time: Time.at(3600),
        owner: user
      )
      allow(task).to receive_message_chain(
        :owner, :created_tasks, :in_progress, :exists?).and_return(false)
      task
    end

    describe '事前条件の検証' do
      context 'statusがuntouched, suspendedの場合' do
        ['untouched', 'suspended'].each do |status|
          it "statusが#{status}の場合、例外が発生しない" do
            task.status = status
            expect{ task.start}.not_to raise_error
          end
        end
      end

      context'statusがuntouched, suspended以外の場合' do
        not_stopped_statuses = 
          Task.statuses.keys.delete_if{ |s| ['untouched', 'suspended'].include?(s) }

        not_stopped_statuses.each do |status|
          it "statusが#{status}の場合、例外が発生する" do
            task.status = status
            expect{ task.start}.to raise_error(
              /statusはuntouchedまたはsuspendedである必要があります。/)
          end
        end
      end
    end

    it 'statusがstartedであること' do
      task.start
      expect(task.status).to eq 'started'
    end

    it 'started_atに現在日時がセットされること' do
      task.start
      expect(task.started_at).to be_within(1).of(Time.zone.now)
    end

    describe '同じユーザが所有するタスクが存在する場合' do
      let(:existing_task) do
        existing_task = Task.new(
          content: 'test',
          target_time: Time.at(1800),
          owner: user
        )
        allow(task).to receive_message_chain(:owner, :created_tasks)
          .and_return(Task.where(owner: user))
        existing_task
      end

      context 'statusが"started"であるタスクが存在する場合' do
        before do
          existing_task.status = :started
          existing_task.save
        end

        it 'falseを返すこと' do
          expect(task.start).to eq false
        end

        it 'errors[:base]にエラーを追加すること' do
          task.start
          expect(task.errors[:base]).to be_include '既に作業中のタスクがあります。'
        end
      end

      context 'statusが"resumed"であるタスクが存在する場合' do
        before do
          existing_task.status = :resumed
          existing_task.save
        end

        it 'falseを返すこと' do
          expect(task.start).to eq false
        end

        it 'errors[:base]にエラーを追加すること' do
          task.start
          expect(task.errors[:base]).to be_include '既に作業中のタスクがあります。'
        end
      end
    end
  end

  describe '#finish' do
    let(:task) do
      Task.new(
        status: :started, 
        content: '内容', 
        target_time: Time.at(3600), 
        started_at: Time.new(2016, 1, 1, 0, 0, 0)
      )
    end

    describe '事前条件の検証' do
      context 'statusがstarted, resumedの場合' do
        ['started', 'resumed'].each do |status|
          it "statusが#{status}の場合、例外が発生しない" do
            task.status = status
            expect{ task.finish }.not_to raise_error
          end
        end
      end

      context 'statusがstarted, resumed以外の場合' do
        not_progress_statuses = 
          Task.statuses.keys.delete_if{ |s| ['started', 'resumed'].include?(s) }

        not_progress_statuses.each do |status|
          it "statusが#{status}の場合、例外が発生する" do
            task.status = status
            expect{ task.finish }.to raise_error(
              /statusはstartedまたはresumedである必要があります。/)
          end
        end
      end
    end

    it 'statusがfinishedであること' do
      task.finish
      expect(task.status).to eq 'finished'
    end

    it 'finished_atに現在日時がセットされること' do
      task.finish
      expect(task.finished_at).to be_within(1).of(Time.zone.now)
    end

    context 'resumed_atに時間がセットされている場合' do
      it 'resumed_atから現在日時までの経過時間がelapsed_timeに加算されること' do
        task.resumed_at   = Time.new(2016, 1, 1, 10, 30, 0)
        task.elapsed_time = Time.at(3600)

        task.finish(Time.new(2016, 1, 1, 11, 30, 0))
        expect(task.elapsed_time).to eq Time.at(7200)
      end
    end

    context 'resumed_atに時間がセットされていない場合' do
      it 'started_atから現在日時までの経過時間がelapsed_timeにセットされること' do
        task.finish(Time.new(2016, 1, 1, 0, 30, 0))
        expect(task.elapsed_time).to eq Time.at(1800)
      end
    end
  end

  describe '#resume' do
    let(:task) do
      task = Task.new(
        status: :suspended, 
        content: '内容', 
        target_time: Time.at(3600), 
        started_at: Time.new(2016, 1, 1, 0, 0, 0),
        owner: user
      )
      allow(task).to receive_message_chain(
        :owner, :created_tasks, :in_progress, :exists?).and_return(false)
      task
    end

    describe '事前条件の検証' do
      context 'statusがsuspendedの場合' do
        it "例外が発生しない" do
          task.status = 'suspended'
          expect{ task.resume }.not_to raise_error
        end
      end

      context 'statusがfinishedの場合' do
        it "例外が発生しない" do
          task.status = 'finished'
          expect{ task.resume }.not_to raise_error
        end
      end

      context'statusがsuspended、finished以外の場合' do
        excluding_suspended_and_finished_statuses = 
          Task.statuses.keys.delete_if{ |s| ['suspended', 'finished'].include?(s) }

        excluding_suspended_and_finished_statuses.each do |status|
          it "statusが#{status}の場合、例外が発生する" do
            task.status = status
            expect{ task.resume}.to raise_error(
              /statusはsuspendedまたはfinishedである必要があります。/)
          end
        end
      end
    end

    it 'statusがresumedであること' do
      task.resume
      expect(task.status).to eq 'resumed'
    end

    it 'resumed_atに現在日時がセットされること' do
      task.resume
      expect(task.resumed_at).to within(1).of(Time.zone.now)
    end

    context 'elapsed_timeがtarget_timeを超えている場合' do
      it 'finish_targeted_atに現在日時がセットされること' do
        task.elapsed_time = Time.at(7200)
        task.resume
        expect(task.finish_targeted_at).to within(1).of(Time.zone.now)
      end
    end

    context 'elapsed_timeがtarget_timeと同値の場合' do
      it 'finish_targeted_atに、現在日時がセットされること' do
        task.elapsed_time = Time.at(3600)
        task.resume(Time.new(2016, 1, 2, 0, 0, 0))
        expect(task.finish_targeted_at).to eq Time.new(2016, 1, 2, 0, 0, 0)
      end
    end

    context 'elapsed_timeがtarget_time未満の場合' do
      it 'finish_targeted_atに、現在日時に残り時間(target_time - elapsed_time)を加算した日時がセットされること' do
        task.elapsed_time = Time.at(3000)
        task.resume(Time.new(2016, 1, 1, 0, 0, 0))
        expect(task.finish_targeted_at).to eq Time.new(2016, 1, 1, 0, 10, 0)
      end
    end

    describe '同じユーザが所有するタスクが存在する場合' do
      let(:existing_task) do
        existing_task = Task.new(
          content: 'test',
          target_time: Time.at(1800),
          owner: user
        )
        allow(task).to receive_message_chain(:owner, :created_tasks)
          .and_return(Task.where(owner: user))
        existing_task
      end

      context 'statusが"started"であるタスクが存在する場合' do
        before do
          existing_task.status = :started
          existing_task.save
        end

        it 'falseを返すこと' do
          expect(task.start).to eq false
        end

        it 'errors[:base]にエラーを追加すること' do
          task.start
          expect(task.errors[:base]).to be_include '既に作業中のタスクがあります。'
        end
      end

      context 'statusが"resumed"であるタスクが存在する場合' do
        before do
          existing_task.status = :resumed
          existing_task.save
        end

        it 'falseを返すこと' do
          expect(task.start).to eq false
        end

        it 'errors[:base]にエラーを追加すること' do
          task.start
          expect(task.errors[:base]).to be_include '既に作業中のタスクがあります。'
        end
      end
    end
  end

  describe '#suspend' do
    let(:task) do
      Task.new(
        status: :started, 
        content: '内容', 
        target_time: Time.at(3600), 
        started_at: Time.new(2016, 1, 1, 0, 0, 0)
      )
    end

    describe '事前条件の検証' do
      context 'statusがstarted, resumedの場合' do
        ['started', 'resumed'].each do |status|
          it "statusが#{status}の場合、例外が発生しない" do
            task.status = status
            expect{ task.suspend}.not_to raise_error
          end
        end
      end

      context 'statusがstarted, resumed以外の場合' do
        not_progress_statuses = 
          Task.statuses.keys.delete_if{ |s| ['started', 'resumed'].include?(s) }

        not_progress_statuses.each do |status|
          it "statusが#{status}の場合、例外が発生する" do
            task.status = status
            expect{ task.suspend}.to raise_error(
              /statusはstartedまたはresumedである必要があります。/)
          end
        end
      end
    end

    it 'statusがsuspendedであること' do
      task.suspend
      expect(task.status).to eq 'suspended'
    end

    it 'suspended_atに現在日時がセットされること' do
      task.suspend
      expect(task.suspended_at).to be_within(1).of(Time.zone.now)
    end

    context 'resumed_atに時間がセットされている場合' do
      it 'resumed_atから現在日時までの経過時間がelapsed_timeに加算されること' do
        task.resumed_at   = Time.new(2016, 1, 1, 10, 30, 0)
        task.elapsed_time = Time.at(3600)

        task.suspend(Time.new(2016, 1, 1, 11, 30, 0))
        expect(task.elapsed_time).to eq Time.at(7200)
      end
    end

    context 'resumed_atに時間がセットされていない場合' do
      it 'started_atから現在日時までの経過時間がelapsed_timeにセットされること' do
        task.suspend(Time.new(2016, 1, 1, 0, 30, 0))
        expect(task.elapsed_time).to eq Time.at(1800)
      end
    end
  end
end
