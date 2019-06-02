class AddTrashedToAllModels < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :trashed, :boolean, default: false
    add_column :archivings, :trashed, :boolean, default: false
    add_column :blog_posts, :trashed, :boolean, default: false
    add_column :forum_posts, :trashed, :boolean, default: false
    add_column :documents, :trashed, :boolean, default: false
    add_column :comments, :trashed, :boolean, default: false
  end
end
