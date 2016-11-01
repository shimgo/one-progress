class TwitterUser < ActiveRecord::Base
  belongs_to :user

  def self.find_or_create_from_auth_hash(auth_hash)
    twitter_user = find_or_initialize_by(uid: auth_hash[:uid])

    if twitter_user.new_record?
      twitter_user.user = User.new(
        username: auth_hash[:info][:nickname], 
        image_url: auth_hash[:info][:image]
      )
      twitter_user.save!
    end

    twitter_user.user
  end
end
