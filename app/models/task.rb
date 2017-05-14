class Task < ActiveRecord::Base
  enum status: {
    untouched: 0,
    started:   1,
    suspended: 2,
    resumed:   3,
    finished:  4
  }

  default_value_for :status, :untouched
  default_value_for :elapsed_time, Time.zone.at(0)

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'

  validates :content, length: { maximum: 200 }, presence: true
  validates :target_time, presence: true
  validate do
    next unless target_time

    errors.add(:target_time, 'は60分以内にしてください') if to_duration(target_time) > 3600
  end

  scope :in_progress, -> { where(status: statuses.values_at(:started, :resumed)) }
  scope :owned, -> { where(user_id: owner.user_id) }

  def finish(called_at = Time.zone.now)
    unless %w[started resumed].include?(status)
      raise "statusはstartedまたはresumedである必要があります。(status: #{status})"
    end

    update!(
      status: :finished,
      finished_at: called_at,
      elapsed_time: calculate_elapsed_time(called_at)
    )
  end

  def resume(called_at = Time.zone.now)
    unless %w[suspended finished].include?(status)
      raise "statusはsuspendedまたはfinishedである必要があります。(status: #{status})"
    end

    if tasks_already_in_progress_exists?
      errors[:base] << '既に作業中のタスクがあります。'
      return
    end

    update!(
      status: :resumed,
      resumed_at: called_at,
      finish_targeted_at: called_at + remaining_time
    )
  end

  def start(called_at = Time.zone.now)
    unless %w[untouched suspended].include?(status)
      raise "statusはuntouchedまたはsuspendedである必要があります。(status: #{status})"
    end

    if tasks_already_in_progress_exists?
      errors[:base] << '既に作業中のタスクがあります。'
      return false
    end

    update!(
      status: :started,
      started_at: called_at,
      finish_targeted_at: called_at + to_duration(target_time)
    )
  end

  def suspend(called_at = Time.zone.now)
    unless %w[started resumed].include?(status)
      raise "statusはstartedまたはresumedである必要があります。(status: #{status})"
    end

    update!(
      status: :suspended,
      suspended_at: called_at,
      elapsed_time: calculate_elapsed_time(called_at)
    )
  end

  def owner?(user)
    return false if user.nil?
    owner.id == user.id
  end

  private

  def calculate_elapsed_time(called_at)
    self.elapsed_time ||= Time.zone.at(0)
    self.elapsed_time + (called_at - (resumed_at || started_at)).to_i
  end

  def to_duration(time)
    Time.zone.at(time.utc.hour * 3600 + time.utc.min * 60 + time.utc.sec).to_i
  end

  def tasks_already_in_progress_exists?
    owner.created_tasks.in_progress.exists?
  end

  def remaining_time
    remaining_time = target_time - elapsed_time
    remaining_time < 0 ? 0 : remaining_time
  end
end
