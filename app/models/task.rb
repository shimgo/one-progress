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

  validates :content, length: { maximum: 200 }, presence: true
  validates :target_time, presence: true

  scope :in_progress, -> { where(status: statuses.values_at(:started, :resumed)) }

  def finish(called_at = Time.zone.now)
    unless ['started', 'resumed'].include?(self.status)
      raise "statusはstartedまたはresumedである必要があります。(status: #{self.status})" 
    end

    update!(
      status: :finished, 
      finished_at: called_at,
      elapsed_time: calculate_elapsed_time(called_at)
    )
  end

  def resume(called_at = Time.zone.now)
    unless self.status == 'suspended'
      raise "statusはsuspendedである必要があります。(status: #{self.status})" 
    end

    remaining_time = target_time - elapsed_time
    update!(
      status: :resumed,
      resumed_at: called_at,
      finish_targeted_at: remaining_time < 0 ? called_at : called_at + remaining_time
    )
  end

  def start(called_at = Time.zone.now)
    unless ['untouched', 'suspended'].include?(self.status)
      raise "statusはuntouchedまたはsuspendedである必要があります。(status: #{self.status})" 
    end

    update!(
      status: :started,
      started_at: called_at, 
      finish_targeted_at: called_at + to_duration(target_time)
    )
  end

  def suspend(called_at = Time.zone.now)
    unless ['started', 'resumed'].include?(self.status)
      raise "statusはstartedまたはresumedである必要があります。(status: #{self.status})" 
    end

    update!(
      status: :suspended, 
      suspended_at: called_at,
      elapsed_time: calculate_elapsed_time(called_at)
    )
  end

  private

  def calculate_elapsed_time(called_at)
    self.elapsed_time ||= Time.at(0)
    self.elapsed_time + (called_at - (resumed_at || started_at)).to_i
  end

  def to_duration(time)
    Time.at(time.hour * 3600 + time.min * 60 + time.sec).to_i
  end

end
