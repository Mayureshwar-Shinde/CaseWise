# config/initializers/audited_ransack.rb

module Audited
  class Audit < ActiveRecord::Base
    # belongs_to :user
    def self.ransackable_attributes(auth_object = nil)
      [
        "action", 
        "associated_id", 
        "associated_type", 
        "auditable_id", 
        "auditable_type",
        "created_at", 
      ]
    end

    def self.ransackable_associations(auth_object = nil)
      ["associated", "auditable", "user"]
    end
  end
end


# ActiveSupport.on_load :active_record do
#   Audited.audit_class = Audit
# end