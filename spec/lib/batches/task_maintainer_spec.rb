require 'rails_helper'
require 'rake'

RSpec.describe Batches::TaskMaintainer do
  describe '::suspend_tasks' do
    let(:current_time) { Time.zone.parse('2017-11-10 10:00:00') }

    before do
      Timecop.freeze
      Timecop.travel(current_time)
    end

    after do
      Timecop.return
    end

    context 'resumed状態のタスクの場合' do
      it 'resumed_atから現在日時までで1日以上経過しているタスクをsuspended状態にすること' do
        task_passed_a_day =
          FactoryGirl.create(:task, :resumed_task, resumed_at: current_time - 1.day)
        Batches::TaskMaintainer.suspend_tasks
        expect(Task.find(task_passed_a_day.id).status).to eq 'suspended'
      end

      it 'resumed_atから現在日時までで1日以上経過していないタスクはresumed状態のままになっていること' do
        task_passed_less_than_a_day =
          FactoryGirl.create(:task, :resumed_task, resumed_at: current_time - 1.day + 1.seconds)
        Batches::TaskMaintainer.suspend_tasks
        expect(Task.find(task_passed_less_than_a_day.id).status).to eq 'resumed'
      end
    end

    context 'started状態のタスクの場合' do
      it 'started_atから現在日時までで1日以上経過しているタスクをsuspended状態にすること' do
        task_passed_a_day =
          FactoryGirl.create(:task, :started_task, started_at: current_time - 1.day)
        Batches::TaskMaintainer.suspend_tasks
        expect(Task.find(task_passed_a_day.id).status).to eq 'suspended'
      end

      it 'started_atから現在日時までで1日以上経過していないタスクはstarted状態のままになっていること' do
        task_passed_less_than_a_day =
          FactoryGirl.create(:task, :started_task, started_at: current_time - 1.day + 1.seconds)
        Batches::TaskMaintainer.suspend_tasks
        expect(Task.find(task_passed_less_than_a_day.id).status).to eq 'started'
      end
    end
  end
end
