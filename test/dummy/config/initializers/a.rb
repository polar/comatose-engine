
::ActionDispatch::Routing::RouteSet.class_eval do
def eval_block(block)
  if block.arity == 1
    raise "You are using the old router DSL which has been removed in Rails 3.1. " <<
              "Please check how to update your routes file at: http://www.engineyard.com/blog/2010/the-lowdown-on-routes-in-rails-3/"
  end
  mapper = ActionDispatch::Routing::Mapper.new(self)
  if default_scope
    mapper.with_default_scope(default_scope, &block)
  else
    mapper.instance_exec(&block)
  end
end
  end