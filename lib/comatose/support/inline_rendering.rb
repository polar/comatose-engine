# Extends the view to support rendering inline comatose pages...
ActionView::Base.class_eval do

  def render_comatose(page_path, params)
    params = {
        :silent => false,
        :locals => { }
    }.merge(params)

    # Checking for the Comatose::EngineController will only work if the
    # route to the controller is under the mount point. A programmer may extend this controller,
    # but unless request.env["SCRIPT_NAME"] is the mount point it won't work.
    # In that case, the programmer needs to specify :comatose_mount.
    if controller.is_a? Comatose::EngineController
      mount = controller.get_mount_point()
    else
      mount = params[:comatose_mount]
    end

    # if mount is not defined the application may just have one Comatose::Engine mounted,
    # Therefore, we assume it's a default.
    if mount
      pages = Comatose::Page.where(:mount => mount, :full_path => path).all
    else
      pages = Comatose::Page.where(:full_path => path).all
    end

    # As of Rails 3.2.8 we don't know how many times or where the Comatose::Engine are mounted.
    # We will raise an error if we find two different pages with different mount points.
    # We always want the full path emanating from the first root-page
    mount_diff = pages.first.mount if pages
    page = pages.reduce() do |t, v|
        rails "mount is not specified" if mount_diff != v.mount
        t.root.position < v.root.position ? t : v
      end

    if page
      # Add the request params to the context...
      params[:locals]['params'] = controller.params
      html = page.to_html( params[:locals] )
    else
      html = params[:silent] ? '' : "<p><tt>#{page_path}</tt> not found</p>"
    end
  end
  
end

