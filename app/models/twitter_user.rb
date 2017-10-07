class TwitterUser < ActiveRecord::Base
  belongs_to :user

  validates :uid, presence: true

  def self.find_or_create_from_auth_hash(auth_hash)
    twitter_user = find_or_initialize_by(uid: auth_hash[:uid])

    if twitter_user.new_record?
      twitter_user.nickname = auth_hash[:info][:nickname]
      twitter_user.user = User.new(
        username: auth_hash[:info][:name],
        image_url: auth_hash[:info][:image]
      )
      twitter_user.save!
    end

    twitter_user
  end
end
