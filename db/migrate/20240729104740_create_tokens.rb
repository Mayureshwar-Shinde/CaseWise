class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens do |t|
      t.datetime :expired_at
      t.text :value

      t.timestamps
    end
  end
end
