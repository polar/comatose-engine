require 'paginating_find.rb'

ActiveRecord::Base.send(:include, PaginatingFind)
ActionView::Base.send(:include, PaginatingFind::Helpers)

puts "THIS IS THE Comatose Engine PaginatingFind Plugin"