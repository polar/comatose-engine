class PagePhotosController < ApplicationController

  #
  # This gets called by the form in the Comatose Admin View
  # when the "Upload and Change" button is clicked.
  #
  def create
    @page_photo = PagePhoto.new(params[:page_photo])
    respond_to do |format|
      if @page_photo.save
        flash[:notice] = 'Photo was successfully created.'
        format.html { redirect_to page_photo_url(@page_photo) }
        format.xml  { head :created, :location => page_photo_url(@page_photo) }
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
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page_photo.errors.to_xml }
        format.js do
          flash[:error] = 'Could not upload photo properly. Is it a photo?.'
          responds_to_parent do
            render :update do |page|
                # update the page with an error message
            end
          end
        end
      end
    end
  end

end
