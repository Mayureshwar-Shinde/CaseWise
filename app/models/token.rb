class Token < ApplicationRecord
  before_create :set_expiration, :generate_value

  private

  def set_expiration
    self.expired_at = 24.hours.from_now
  end

  def generate_value
    self.value = SecureRandom.hex(16)
  end
end
