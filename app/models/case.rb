class Case < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_to, class_name: 'User', foreign_key: 'assigned_to_id', optional: true

  enum :status, %i[ open in_progress resolved closed assigned ], _default: 'open'

  validates :case_number, uniqueness: true
  validates :title, :description, presence: true
  validates_presence_of :user

  before_validation :generate_case_number, on: :create

  has_many :notes, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :communications, dependent: :destroy

  audited associated_with: :user, except: ["user_id", "case_number"]

  def self.ransackable_attributes(auth_object = nil)
    [ "assigned_to_id", "case_number", "created_at", "description", "status", "title", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["assigned_to", "user"]
  end


  private

  def generate_case_number
    self.case_number = "##{SecureRandom.hex(3).upcase}"
  end

end
