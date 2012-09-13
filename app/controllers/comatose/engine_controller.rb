module Comatose
  class EngineController < ActionController::Base
    protect_from_forgery

    protected

    #
    # Gets the Engine Mountpoint from the Rack Environment.
    # This is dicey at best. However, for routes we are always looking at the
    # end of the route for the controller/action, so that ENV["SCRIPT_NAME"] from Rack
    # *should* be this Engine's mount_point.
    #   mount Comatose::Engine => "/site1"
    # will have a ENV["SCRIPT_NAME"] == "/site1"
    # Even if you had an engine mounted at variable mount points, such as
    #  mount Comatose::Engine => "/:user"
    # then "/#{params[:user]}" == ENV["SCRIPT_NAME"]
    #
    def get_mount_point
      mount = session["SCRIPT_NAME"] || request.env["SCRIPT_NAME"]
    end

  end
end
