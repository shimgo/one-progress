FactoryGirl.define do
  factory :task do
    association :owner, factory: :user
    status :untouched
    sequence(:content) { |n| "タスク#{n}" }
    target_time Time.utc(2000, 1, 1, 0, 30, 0)
    elapsed_time Time.utc(2000, 1, 1, 0, 0, 0)

    trait :invalid_task do
      content ''
    end

    trait :started_task do
      status :started
      started_at Time.now.ago(1800).utc
    end

    trait :suspended_task do
      status :suspended
      started_at Time.now.ago(3600).utc
      suspended_at Time.now.ago(3000).utc
    end

    trait :resumed_task do
      status :resumed
      started_at Time.now.ago(3600).utc
      suspended_at Time.now.ago(3000).utc
      resumed_at Time.now.ago(2400).utc
    end
  end
end
