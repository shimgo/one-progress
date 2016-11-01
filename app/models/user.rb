class User < ActiveRecord::Base
  has_many :created_tasks, class_name: 'Task', foreign_key: 'user_id'
  has_one :twitter_user, :dependent => :destroy

  default_value_for :is_active, true

  def self.find_or_create_from_auth_hash(auth_hash)
    if auth_hash[:provider] == 'twitter'
      TwitterUser.find_or_create_from_auth_hash(auth_hash)
    end
  end
end
