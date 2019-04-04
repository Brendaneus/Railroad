class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.references :archiving, foreign_key: true
      t.integer :local_id, index: true
      t.string :url
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
