FactoryGirl.define do
  factory :twitter_user do
    sequence(:uid) {|n| "uid#{n}"}
    sequence(:nickname) {|n| "nicknamme#{n}"}

    trait :with_user do
      user
    end
  end
end
