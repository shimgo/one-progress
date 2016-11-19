# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
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
