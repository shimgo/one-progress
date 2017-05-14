class User < ActiveRecord::Base
  attr_accessor :remember_token

  has_many :created_tasks, class_name: 'Task', foreign_key: 'user_id', dependent: :nullify
  has_one :twitter_user, dependent: :destroy
  has_one :guest_user, dependent: :destroy

  default_value_for :is_active, true
  default_value_for :image_url, ''

  validates :username, presence: true, length: { maximum: 20 }

  def self.find_or_create_from_auth_hash(auth_hash)
    return unless auth_hash[:provider] == 'twitter'

    twitter_user = TwitterUser.find_or_create_from_auth_hash(auth_hash)

    if twitter_user.user.username != auth_hash[:info][:name]
      twitter_user.user.update(username: auth_hash[:info][:name])
    end

    twitter_user.user
  end

  def self.digest(string)
    cost =
      ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    @remember_token = User.new_token
    update_attributes(remember_digest: User.digest(@remember_token))
  end

  def forget
    update_attributes(remember_digest: nil)
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
