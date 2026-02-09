# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_01_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "product_bookmarks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_product_bookmarks_on_product_id"
    t.index ["user_id", "product_id"], name: "index_product_bookmarks_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_bookmarks_on_user_id"
  end

  create_table "product_stats", force: :cascade do |t|
    t.decimal "avg_aftertaste"
    t.decimal "avg_flavor_score"
    t.decimal "avg_foam"
    t.decimal "avg_overall_score"
    t.decimal "avg_richness"
    t.decimal "avg_solubility"
    t.decimal "avg_sweetness"
    t.integer "bookmarks_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "reviews_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_stats_on_product_id"
  end

  create_table "product_taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "tag_id"], name: "index_product_taggings_on_product_id_and_tag_id", unique: true
    t.index ["product_id"], name: "index_product_taggings_on_product_id"
    t.index ["tag_id"], name: "index_product_taggings_on_tag_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "brand", null: false
    t.integer "calorie"
    t.decimal "carbohydrate", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "fat", precision: 5, scale: 2
    t.string "flavor"
    t.string "image_url"
    t.string "name", null: false
    t.integer "price", null: false
    t.decimal "protein", precision: 5, scale: 2
    t.integer "protein_type", default: 0, null: false
    t.string "reference_url"
    t.datetime "updated_at", null: false
  end

  create_table "review_likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "review_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["review_id"], name: "index_review_likes_on_review_id"
    t.index ["user_id", "review_id"], name: "index_review_likes_on_user_id_and_review_id", unique: true
    t.index ["user_id"], name: "index_review_likes_on_user_id"
  end

  create_table "review_taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "review_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["review_id", "tag_id"], name: "index_review_taggings_on_review_id_and_tag_id", unique: true
    t.index ["review_id"], name: "index_review_taggings_on_review_id"
    t.index ["tag_id"], name: "index_review_taggings_on_tag_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "aftertaste", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "flavor_score", null: false
    t.integer "foam", null: false
    t.integer "overall_score", null: false
    t.bigint "product_id", null: false
    t.integer "richness", null: false
    t.integer "solubility", null: false
    t.integer "sweetness", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "product_bookmarks", "products"
  add_foreign_key "product_bookmarks", "users"
  add_foreign_key "product_stats", "products"
  add_foreign_key "product_taggings", "products"
  add_foreign_key "product_taggings", "tags"
  add_foreign_key "review_likes", "reviews"
  add_foreign_key "review_likes", "users"
  add_foreign_key "review_taggings", "reviews"
  add_foreign_key "review_taggings", "tags"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
end
