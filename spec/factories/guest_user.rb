FactoryGirl.define do
  factory :guest_user do
    trait :with_user do
      after :build do |guest_user|
        guest_user.user = FactoryGirl.build(:user)
      end
    end
  end
end
