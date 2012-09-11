# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120910223341) do

  create_table "comatose_page_versions", :force => true do |t|
    t.integer  "page_id"
    t.integer  "version"
    t.integer  "parent_id"
    t.string   "mount"
    t.text     "full_path",                             :default => ""
    t.string   "title"
    t.string   "slug"
    t.string   "keywords"
    t.text     "body"
    t.string   "filter_type",             :limit => 25, :default => "Textile"
    t.string   "author"
    t.integer  "position",                              :default => 0
    t.date     "created_on"
    t.date     "updated_on"
    t.string   "page_photo_file_name"
    t.string   "page_photo_content_type"
    t.integer  "page_photo_file_size"
    t.datetime "page_photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comatose_page_versions", ["page_id"], :name => "index_comatose_page_versions_on_page_id"

  create_table "comatose_pages", :force => true do |t|
    t.integer  "parent_id"
    t.string   "mount"
    t.text     "full_path",                             :default => ""
    t.string   "title"
    t.string   "slug"
    t.string   "keywords"
    t.text     "body"
    t.string   "filter_type",             :limit => 25, :default => "Textile"
    t.string   "author"
    t.integer  "position",                              :default => 0
    t.integer  "version"
    t.date     "created_on"
    t.date     "updated_on"
    t.string   "page_photo_file_name"
    t.string   "page_photo_content_type"
    t.integer  "page_photo_file_size"
    t.datetime "page_photo_updated_at"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

end
