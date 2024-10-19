class CreateCases < ActiveRecord::Migration[7.1]
  def change
    create_table :cases do |t|
      t.string :case_number
      t.string :title
      t.text :description
      t.integer :status, default: 0
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }

      t.timestamps
      t.index [:case_number], unique: true
    end
  end
end
