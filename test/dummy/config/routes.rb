Rails.application.routes.draw do
  root :to => "comatose/pages#show"
  mount Comatose::Engine => "/comatose"

  # We cannot test this having multiple mount points because
  # named routes do not work in the test harness for the controllers.
  # They always grab the last mount point, which renders trying to
  # write "tests" for multiple mount points impossible. However, this
  # does work in practice.
  #mount Comatose::Engine => "/second"
end



