class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :ip
      t.string :remember_digest
      t.timestamp :last_active
      t.timestamps
    end

    remove_column :users, :remember_digest, :string
    add_column :users, :last_active, :timestamp
  end
end
