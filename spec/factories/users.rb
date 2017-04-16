FactoryGirl.define do
  factory :user do
    sequence(:username) {|n| "ユーザ#{n}"}

    trait :invalid_user do
      username ''
    end

    trait :with_started_task do
      after(:build) do |user|
        user.created_tasks << FactoryGirl.build(:task, status: :started)
      end
    end

    trait :with_untouched_task do
      after(:build) do |user|
        user.created_tasks << FactoryGirl.build(:task, status: :untouched)
      end
    end

    trait :with_twitter_user do
      twitter_user FactoryGirl.build(:twitter_user)
    end
  end
end
