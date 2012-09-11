module Comatose
  class AdminsController < Comatose::EngineController
    unloadable

    layout 'comatose/admin'

    def index
      @root_pages = fetch_root_pages
      @reorder_path = reorder_admins_path;
    end

    def new
      @root_pages = fetch_root_pages
      @page = Comatose::Page.new :title => '', :slug => "", :parent_id => (params[:parent_id] || nil)
      true
    end

    # Called by a remote form for both Preview and Create
    def create
      mount        = get_mount_point
      @page        = Comatose::Page.new(params[:page])
      @page.mount  = mount
      @page.author = fetch_author_name
      if params[:commit] == "Create Page"
        if @page.save
          flash[:notice] = "Created page '#{@page.title}'"
          @status      = flash[:notice]
          @disposition = "success"
          @redirect_path = admins_path
        else
          @disposition = "error"
          @page_status = "Could Not Create Page"
          @page_errors = @page.errors.full_messages
          @root_pages = fetch_root_pages
        end
      end
      compile_preview
    end

    def edit
      @root_pages = fetch_root_pages
      @page       = Comatose::Page.find params[:id]
    end

    # Called by a remote form for both Preview and Update
    def update
      params[:page][:updated_on] = Time.now
      params[:page][:author]     = fetch_author_name
      @page = Comatose::Page.find params[:id]
      if params[:commit] == "Save Changes"
        if @page.update_attributes(params[:page])
          flash[:notice] = "Saved changes to '#{@page.title}'"
          @disposition = "success"
          @redirect_path = admins_path
        else
          @disposition = "error"
          @page_status = "Could Not Create Page"
          @page_errors = @page.errors.full_messages
          @root_pages = fetch_root_pages
        end
      end
      compile_preview
    end

    # Deletes the specified page
    def destroy
      @page = Comatose::Page.find params[:id]
      @page.destroy
      flash[:notice] = "Deleted page '#{@page.title}'"
      redirect_to admins_path
    end

    # Non-standard routes

    #
    # Gets an Ajax call from JSTree to reposition the new child.
    # Params
    #  id=
    #  position=
    #
    def reorder
      @page = Comatose::Page.find params[:id]
      if @page
        if @page.position != params[:position].to_i
          pos = params[:position].to_i
          length = @page.parent ? @page.parent.children.length : Comatose::Page.where(:mount => @page.mount, :parent_id => nil).count
          if (pos < 0 || length < pos)
            render :status => 500
            return
          else
            @page.remove_from_list
            @page.insert_at params[:position].to_i
            @page.save
          end
        end
      end
      render :nothing => true, :status => 200
    end

    # Comparative view between two versions of a page's content
    # Params
    #   id
    #   version  - number.
    def versions
      @page        = Comatose::Page.find params[:id]
      @version_num = (params[:version] || @page.versions.length).to_i
      @version     = @page.versions.find_by_version(@version_num)
    end

    # Reverts a page to a specific version...
    def set_version
      @page        = Comatose::Page.find params[:id]
      @version_num = params[:version]
      @page.revert_to!(@version_num)
      flash[:notice] = "Page #{@page.title} has been set to version #{@version_num}."
      redirect_to admins_path
    end

    def export
      if Comatose.config.allow_import_export
        send_data(page_to_hash(Comatose::Page.root).to_yaml,
                  :disposition => 'attachment',
                  :type => 'text/yaml',
                  :filename => "pages.yml")
      else
        flash[:notice] = "Export is not allowed"
        redirect_to admins_path
      end
    end

    def import
      importer = Comatose::Importer.new(params[:importer])
      importer.save
      mount = get_mount_point()
      data = YAML::load(File.open(importer.import_file.path))
      hash_to_page_tree(mount, data, nil)
      importer.destroy
      flash[:notice] = "Pages Imported Successfully"
    rescue
      flash[:notice] = "Could not import file. Not YAML?"
    ensure
      redirect_to admins_path
    end

    protected

    def fetch_root_pages
      mount = get_mount_point()
      roots = Comatose::Page.where(:mount => mount, :parent_id => nil).all
      roots.nil? ? [] : [roots].flatten
    end

    def compile_preview
      begin
        page        = Comatose::Page.new(params[:page])
        page.author = fetch_author_name
        if params.has_key? :version
          content = page.to_html({ 'params' => params.stringify_keys, 'version' => params[:version] })
        else
          content = page.to_html({ 'params' => params.stringify_keys })
        end
      rescue SyntaxError
        content = "<p>There was an error generating the preview.</p><p><pre>#{$!.to_s.gsub(/\</, '&lt;')}</pre></p>"
      rescue
        content = "<p>There was an error generating the preview.</p><p><pre>#{$!.to_s.gsub(/\</, '&lt;')}</pre></p>"
      ensure
        @html = content.html_safe
      end
    end

    def fetch_author_name
      if defined? get_author
        get_author
      end
    end

    ##
    #
    # Returns a path to plugin layout, if it's unspecified, otherwise
    # a path to an application layout...
    #
    def get_page_layout(params)
        params[:layout]
    end

    def page_to_hash(page)
      data = page.attributes.clone
      # Pull out the specific, or unnecessary fields
      %w(id parent_id updated_on author position version created_on full_path mount created_at updated_at).each { |key| data.delete(key) }
      if !page.children.empty?
        data['children'] = []
        page.children.each do |child|
          data['children'] << page_to_hash(child)
        end
      end
      data
    end

    def hash_to_page_tree(mount, hsh, page)
      child_ary = hsh.delete 'children'
      if page.nil?
        page = Comatose::Page.new(hsh)
      else
        page.update_attributes(hsh)
      end
      page.mount = mount
      page.save
      child_ary.each do |child_hsh|
        if child_pg = page.children.find_by_slug(child_hsh['slug'])
          hash_to_page_tree(mount, child_hsh, child_pg)
        else
          hash_to_page_tree(mount, child_hsh, page.children.build)
        end
      end if child_ary
    end

  end # AdminsController
end   # module Comatose
