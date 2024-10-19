class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :case, null: false, foreign_key: true
      t.references :case_manager, null: false, foreign_key: { to_table: :users }
      t.references :dispute_analyst, null: false, foreign_key: { to_table: :users }
      t.date :date
      t.time :time
      t.integer :status

      t.timestamps
    end
  end
end
