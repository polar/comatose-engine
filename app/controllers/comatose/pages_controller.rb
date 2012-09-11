module Comatose

# The controller for serving cms content...
  class PagesController < Comatose::EngineController

    unloadable

    # Render a specific page
    def show
      respond_to do |format|
        format.html do
          page = Comatose::Page.where(:id => params[:id]).first
          if page.nil?
            mount  = get_mount_point()

            path = params[:page_path] || ""
            path = "/#{path}".squeeze("/") unless path.blank?

            # We always want the full path emanating from the first root-page
            pages = Comatose::Page.where(:mount => mount, :full_path => path).all
            page = pages.reduce() {|t,v| t.root.position < v.root.position ? t : v }

            status = nil
            if page.nil?
              page   = Comatose::Page.find_by_path(mount, '404')
              status = 404
            end
          else
            mount  = get_mount_point()
            page   = Comatose::Page.find_by_path(mount, '404')
            status = 404

            if page.nil?
              render :nothing => true, :status => status
              return
              #raise ActiveRecord::RecordNotFound.new("Comatose page not found ")
            end
          end
          # if it's still nil, well, send a 404 status
          if page.nil?
            render :nothing => true, :status => status
          else
            # Make the page access 'safe'
            @page = page
            layout = get_page_layout
            render :text => page.to_html({ 'params' => params.stringify_keys }), :layout => layout, :status => status
          end
        end
      end
    end

    protected

    # Returns a path to plugin layout, if it's unspecified, otherwise
    # a path to an application layout...
    def get_page_layout
      params[:layout] ||  "comatose/content"
    end

  end
end

