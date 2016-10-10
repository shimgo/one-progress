class Task < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'

  validates :content, length: { maximum: 300 }, presence: true

  scope :untouched, -> { where(start_time: nil, end_time: nil) }
  scope :in_progress, -> { where.not(start_time: nil).where(end_time: nil) }
end
