class Task < ActiveRecord::Base
  enum status: { 
    untouched: 0,
    started:   1,
    suspended: 2,
    resumed:   3,
    finished:  4
  }

  default_value_for :status, :untouched
  default_value_for :elapsed_time, Time.at(0)

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'

  validates :content, length: { maximum: 300 }, presence: true

  scope :in_progress, -> { where(status: statuses.values_at(:started, :resumed)) }

  def finish
    update(
      status: :finished, 
      finished_at: Time.zone.now,
      elapsed_time: calculate_elapsed_time
    )
  end

  def resume
    remaining_time = target_time - elapsed_time
    update(
      status: :resumed,
      resumed_at: Time.zone.now,
      finish_targeted_at: remaining_time < 0 ? Time.zone.now : Time.zone.now + remaining_time
    )
  end

  def start
    update(
      status: :started,
      started_at: Time.zone.now, 
      finish_targeted_at: Time.zone.now + to_duration(target_time)
    )
  end

  def suspend
    update(
      status: :suspended, 
      suspended_at: Time.zone.now,
      elapsed_time: calculate_elapsed_time
    )
  end

  private

  def calculate_elapsed_time
    self.elapsed_time ||= Time.at(0)
    self.elapsed_time + (Time.now - (resumed_at || started_at)).to_i
  end

  def to_duration(time)
    Time.at(time.hour * 3600 + time.min * 60 + time.sec).to_i
  end

end
