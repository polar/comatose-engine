module Comatose
  module AdminsHelper

    # Used in the Page Form to build an indented drop-down list of pages
    def tree_select_box(nodes, selected= nil, hide= nil, label="Parent", add_initial=false)
      level      = 0
      select_box = add_initial ? "<option value=0>No #{label}</option>\n" : ""
      selected = nodes[0].id if !nodes.empty? && selected.nil? && ! add_initial
      nodes.each { |node| select_box += add_select_tree_node(node, selected, level, hide) }
      select_box += ''
      select_box = select_box.html_safe
      return select_box
    end

    # Called by tree_select_box
    def add_select_tree_node(node, selected, level, hide)
      padding = "&nbsp;" * level * 4
      padding += '&raquo; ' unless level==0
      hide_values = Array.new
      hide_values << hide if hide
      if node.id == selected
        select_box = %Q|<option value="#{node.id}" selected="true">#{padding}#{node.title}</option>\n|
      else
        if hide_values.include?(node.id)
          select_box = ''
        else
          select_box = %Q|<option value="#{node.id}">#{padding}#{node.title}</option>\n|
        end
      end
      node.children.each do |child|
        select_box += add_select_tree_node(child, selected, level + 1, hide) unless hide_values.include?(node.id)
      end
      select_box
    end
  end
end