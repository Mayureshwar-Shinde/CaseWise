class Appointment < ApplicationRecord
  belongs_to :case
  belongs_to :case_manager, class_name: 'User', foreign_key: 'case_manager_id'
  belongs_to :dispute_analyst, class_name: 'User', foreign_key: 'dispute_analyst_id'

  enum :status, %i[ scheduled pending completed cancelled  ], _default: 'pending'

  validates :date, :time, presence: true
  validate :valid_time_range

  audited associated_with: :case_manager

  def datetime
    DateTime.parse("#{date} #{time}")
  end

  def self.ransackable_attributes(auth_object = nil)
    ["case_manager_id", "date", "dispute_analyst_id", "status", "time", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["case", "case_manager", "dispute_analyst"]
  end

  private

  def valid_time_range
    return if date.nil? || time.nil?
    if date < Date.today
      errors.add(:date, 'must be in the future')
    elsif date == Date.today && time.strftime("%H:%M") < Time.current.strftime("%H:%M")
      errors.add(:time, "can't be in the past for today's date")
    end
  end
end
