FactoryGirl.define do
  factory :twitter_user do
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:nickname) { |n| "nicknamme#{n}" }

    trait :with_user do
      after :build do |twitter_user|
        twitter_user.user = FactoryGirl.build(:user)
      end
    end
  end
end
