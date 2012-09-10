module Comatose
  class PhotosController < Comatose::ApplicationController

    #
    # This gets called by the form in the Comatose Admin View
    # when the "Upload and Change" button is clicked.
    #
    def create
      @page = Comatose::Page.find(params[:page][:id])
      if @page
        respond_to do |format|
          format.js do
            responds_to_parent do
              render :update do |page|
                #
                # Change the page.
                # Render the photo so it shows on the users
                # page.
                page.replace_html "page_photo", :partial => 'page_photo', :object => @page_photo
                # Replace the input field in the form to contain the just created
                # page_photo id, so when the Save Changes button is clicked, we have the
                # page_photo_id.
                page.replace_html "page_photo_input",
                                  "<input id='page_page_photo_id' name='page[page_photo_id]' type='hidden' value='#{@page_photo.id}'/>"
              end
            end
          end
      end
    end

    end
  end
end