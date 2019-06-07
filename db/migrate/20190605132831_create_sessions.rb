class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :ip
      t.string :remember_digest
    end

    remove_column :users, :remember_digest
  end
end
