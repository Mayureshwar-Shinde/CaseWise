class Note < ApplicationRecord
  belongs_to :case
  belongs_to :user

  validates :content, presence: true

  audited associated_with: :user, except: ["user_id", "case_id"]
end
