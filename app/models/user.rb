class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :age, :date_of_birth, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :age, numericality: { only_integer: true, greater_than: 0 }
  validate :date_validation

  has_one_attached :avatar
  validates :avatar, content_type: %w[ image/png image/jpeg image/jpg ],
                     # dimension: { width: { min: 40, max: 1600 },
                     #              height: { min: 40, max: 1200 },
                     #              message: 'is not given between dimensions (1200 x 1600)' },
                     size: { less_than: 10.megabytes,
                             message: 'size should be less than 10mb' }

  has_many :cases, dependent: :destroy
  has_many :assigned_cases, class_name: 'Case', foreign_key: 'assigned_to_id', dependent: :destroy

  has_many :notes, dependent: :destroy

  has_many :appointments, foreign_key: 'case_manager_id', dependent: :destroy
  has_many :analyst_appointments, class_name: 'Appointment', foreign_key: 'dispute_analyst_id', dependent: :destroy

  has_many :sent_communications, class_name: 'Communication', foreign_key: 'from_id', dependent: :destroy
  has_many :received_communications, class_name: 'Communication', foreign_key: 'to_id', dependent: :destroy

  enum role_type: %i[case_manager dispute_analyst], _default: 'dispute_analyst'
  enum status: %i[active suspended], _default: 'active'

  audited
  has_associated_audits

  def full_name
    return "#{first_name} #{last_name}"
  end

  def phone
    '+16175551212'
  end

  def self.ransackable_attributes(auth_object = nil)
    ["age", "created_at", "date_of_birth", "email", "encrypted_password", "first_name", "id", "id_value", "last_name", "phone", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role_type", "status", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["avatar_attachment", "avatar_blob", "cases"]
  end

  private

  def date_validation
    return if date_of_birth.nil? || date_of_birth < Date.today
    errors.add(:date_of_birth, 'must be in the past')
  end
end
