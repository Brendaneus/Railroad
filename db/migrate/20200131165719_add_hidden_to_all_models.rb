class AddHiddenToAllModels < ActiveRecord::Migration[6.0]
  def change
    add_column :archivings, :hidden, :boolean, default: false
    add_column :blog_posts, :hidden, :boolean, default: false
    add_column :forum_posts, :hidden, :boolean, default: false
    add_column :documents, :hidden, :boolean, default: false
    add_column :suggestions, :hidden, :boolean, default: false
    add_column :comments, :hidden, :boolean, default: false
    add_column :users, :hidden, :boolean, default: false
  end
end
