class CreateBlogPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :subtitle
      t.text :content
      t.boolean :motd, default: false

      t.timestamps
    end
  end
end
