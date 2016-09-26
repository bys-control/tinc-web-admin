Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope 'api' do
    get '/dump', to: 'api#dump'
    get '/info', to: 'api#info'
  end
end
