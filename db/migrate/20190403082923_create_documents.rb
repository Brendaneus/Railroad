class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.references :article, polymorphic: true, index: true
      t.integer :local_id, index: true
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
