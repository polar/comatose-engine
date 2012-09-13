module Comatose
  class Importer
    extend  ActiveModel::Callbacks
    include ActiveModel::Validations

    include Paperclip::Glue

    define_model_callbacks :save
    define_model_callbacks :destroy

    validate :no_attachement_errors

    attr_accessor :id, :import_file_file_name, :import_file_file_size, :import_file_content_type, :import_file_updated_at

    has_attached_file :import_file,
                      :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                      :url  => "/system/:attachment/:id/:style/:filename"

    def initialize(args = { })
      args.each_pair do |k, v|
        self.send("#{k}=", v)
      end
      @id = self.class.next_id
    end

    def update_attributes(args = { })
      args.each_pair do |k, v|
        self.send("#{k}=", v)
      end
    end

    def save
       run_callbacks :save do
       end
    end

    def destroy
      run_callbacks :destroy do
      end
    end

    # Needed for using form_for Importer::new(), :url => ..... do
    def to_key
      [:importer]
    end

    # Need a differentiating for each new Importer.
    def self.next_id
      @@id += 1
    end

    # Initialize beginning id for something mildly unique.
    @@id = Time.now.to_i

  end
end