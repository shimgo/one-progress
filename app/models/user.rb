class User < ActiveRecord::Base
  attr_accessor :remember_token

  has_many :created_tasks, class_name: 'Task', foreign_key: 'user_id'
  has_one :twitter_user, :dependent => :destroy
  has_one :guest_user, :dependent => :destroy

  default_value_for :is_active, true
  default_value_for :image_url, ''

  def self.find_or_create_from_auth_hash(auth_hash)
    if auth_hash[:provider] == 'twitter'
      TwitterUser.find_or_create_from_auth_hash(auth_hash)
    end
  end

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
