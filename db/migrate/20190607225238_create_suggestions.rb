class CreateSuggestions < ActiveRecord::Migration[6.0]
  def change
    create_table :suggestions do |t|
      t.references :citation, null: false, polymorphic: true
      t.references :user, foreign_key: true
      t.string :name
      t.string :title
      t.text :content
      t.boolean :trashed, default: false

      t.timestamps
    end
  end
end
