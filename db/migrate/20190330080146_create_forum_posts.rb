class CreateForumPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :forum_posts do |t|
      t.references :user, foreign_key: true
      t.string :title
      t.text :content
      t.boolean :motd
      t.boolean :sticky

      t.timestamps
    end
  end
end
