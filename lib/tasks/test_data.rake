namespace :test_data do
  desc "動作確認用データの作成"
  task create: :environment do
    1.upto(200) do |i|
      Task.create(
        status: :started,
        started_at: Time.now,
        finish_targeted_at: Time.now + 1800,
        content: "タスク#{i}",
        target_time: Time.at(1800),
        owner: User.new(
          username: "ユーザ#{i}",
          guest_user: GuestUser.new
        )
      )
    end
  end
end
