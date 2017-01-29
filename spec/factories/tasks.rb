FactoryGirl.define do
  factory :task do
    association :owner, factory: :user
    status :untouched
    sequence(:content) {|n| "タスク#{n}"}
    target_time Time.utc(2000,1,1,0,30,0)
    elapsed_time Time.utc(2000,1,1,0,0,0)
  end
end
