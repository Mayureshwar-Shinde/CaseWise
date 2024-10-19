class Communication < ApplicationRecord
  belongs_to :case, optional: false
  belongs_to :from, class_name: 'User', foreign_key: 'from_id', optional: false
  belongs_to :to, class_name: 'User', foreign_key: 'to_id', optional: false

  validates :subject, :message, presence: true
  enum message_type: %i[ sms email ], _default: 'sms'

  audited associated_with: :from

  def self.ransackable_attributes(auth_object = nil)
    ["from_id", "message_type", "subject", "to_id", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["from", "to"]
  end
end
