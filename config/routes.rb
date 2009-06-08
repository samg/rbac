
ActionController::Routing::Routes.draw do |map|
  map.resources :roles, :controller => 'rbac/roles'
  map.resources :users, :controller => 'rbac/users'
end
