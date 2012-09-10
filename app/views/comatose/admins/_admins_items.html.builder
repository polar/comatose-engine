
def exclude_links
  []
end

def exclude_matches
  [/\-template$/]
end

def excluded?(page)
  exclude_links.include?(page.slug) || exclude_matches.reduce(false) { |v, m| v || page.slug.match(m) }
end

def subpages(page)
  page.children.order(:position).all.reduce([]) { |v, p| !excluded?(p) ? v + [p] : v }
end

def do_page(page, xml)
# Create the page-level links...
  links = []
  if !page.nil? and !page.versions.nil? and page.versions.length > 0
    links << link_to(pluralize(page.versions.length, 'revision', 'revisions'), versions_admin_path(page))
  end

  links << link_to('add child page', new_admin_path(:parent_id => page.id),
                   :title => "Add a child to '#{page.title}'",
                   :class => 'add-page')

  unless @root_pages.include? page
    links << button_to('delete', admin_path(page), :method => :delete,
                       :confirm     => 'This will delete this page, and any children. Are you sure?',
                       :title       => "Delete page '#{page.title}' and all it's children",
                       :class       => 'delete-page',
                       :onmouseover => "ComatoseList.item_hover('page_#{page.id}', 'over', true)",
                       :onmouseout  => "ComatoseList.item_hover('page_#{page.id}', 'out', true)")
  end
    xml.li(:id => "page_#{page.id}") {
      xml.a page.title, :href => edit_admin_path(page)
            xml.div(:class => "commands") {
              xml.span "Created on #{page.created_on}"
              if !page.author.nil? and !page.author.empty?
                xml.span "by #{page.author}"
              end
              if !page.nil? and !page.versions.nil? and page.versions.length > 0
                xml << link_to(pluralize(page.versions.length, 'revision', 'revisions'), versions_admin_path(page))
              end
                xml << link_to('add child page', new_admin_path(:parent_id => page.id),
                               :title => "Add a child to '#{page.title}'",
                               :class => 'add-page')
              unless @root_pages.include? page
                xml << link_to('delete', "#",
                                 :title       => "Delete page '#{page.title}' and all it's children",
                                 :class       => 'delete-page',
                                 :data_delete_form => "delete_form_#{page.id}")
              end
              xml.div(:id => "delete_form_#{page.id}", :class => "delete_form") {
                xml << form_for(page, :url => admin_path(page), :method => :delete) do |form|
                  form.label "Do you really want to delete this page?"
                  form.submit( 'Delete', :class => "btn btn-small")
                end
                xml.a("Cancel", :href => "#", :class => "delete-cancel")
              }
            }
      subpages(page).tap do |pages|
        xml.ul do
          pages.each do |chpage|
            do_page(chpage, xml)
          end
        end if pages.size > 0
      end
    }
end

xml.ul(:class => "jstree-open") {
  @root_pages.each do |page|
    do_page(page, xml);
  end if @root_pages
}

