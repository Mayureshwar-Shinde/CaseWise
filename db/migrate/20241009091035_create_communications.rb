class CreateCommunications < ActiveRecord::Migration[7.1]
  def change
    create_table :communications do |t|
      t.references :case, null: false, foreign_key: true
      t.references :from, null: false, foreign_key: { to_table: :users }
      t.references :to, null: false, foreign_key: { to_table: :users }
      t.string :subject
      t.text :message
      t.integer :message_type, default: 0

      t.timestamps
    end
  end
end
