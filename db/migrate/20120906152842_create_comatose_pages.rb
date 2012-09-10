class CreateComatosePages < ActiveRecord::Migration
  def up
    create_table :comatose_pages do |t|
      t.integer    "parent_id"
      t.text       "full_path",   :default => ''
      t.string     "title",       :limit => 255
      t.string     "slug",        :limit => 255
      t.string     "keywords",    :limit => 255
      t.text       "body"
      t.string     "filter_type", :limit => 25, :default => "Textile"
      t.string     "author",      :limit => 255
      t.integer    "position",    :default => 0
      t.integer    "version"
      t.date       "created_on"
      t.date       "updated_on"
      t.attachment "page_photo"
      t.references "author_user"
      t.timestamps
    end
    Comatose::Page.create_versioned_table
  end

  def down
    drop_table :comatose_pages
    Comatose::Page.drop_versioned_table
  end
end
