# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_31_165719) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "archivings", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trashed", default: false
    t.boolean "hidden", default: false
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.text "content"
    t.boolean "motd", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trashed", default: false
    t.boolean "hidden", default: false
  end

  create_table "comments", force: :cascade do |t|
    t.string "post_type"
    t.integer "post_id"
    t.integer "user_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trashed", default: false
    t.boolean "hidden", default: false
    t.index ["post_type", "post_id"], name: "index_comments_on_post_type_and_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "article_type"
    t.integer "article_id"
    t.integer "local_id"
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trashed", default: false
    t.boolean "hidden", default: false
    t.index ["article_type", "article_id"], name: "index_documents_on_article_type_and_article_id"
    t.index ["local_id"], name: "index_documents_on_local_id"
  end

  create_table "forum_posts", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.text "content"
    t.boolean "motd", default: false
    t.boolean "sticky", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trashed", default: false
    t.boolean "hidden", default: false
    t.index ["user_id"], name: "index_forum_posts_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "ip"
    t.string "remember_digest"
    t.datetime "last_active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "suggestions", force: :cascade do |t|
    t.string "citation_type", null: false
    t.integer "citation_id", null: false
    t.integer "user_id"
    t.string "name"
    t.string "title"
    t.text "content"
    t.boolean "trashed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "hidden", default: false
    t.index ["citation_type", "citation_id"], name: "index_suggestions_on_citation_type_and_citation_id"
    t.index ["user_id"], name: "index_suggestions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trashed", default: false
    t.text "bio"
    t.datetime "last_active"
    t.boolean "hidden", default: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", limit: 8, null: false
    t.string "event", null: false
    t.string "name"
    t.string "whodunnit"
    t.boolean "hidden", default: false
    t.text "object", limit: 1073741823
    t.text "object_changes", limit: 1073741823
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "users"
  add_foreign_key "forum_posts", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "suggestions", "users"
end
