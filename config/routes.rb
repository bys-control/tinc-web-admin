Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope 'api' do
    get '/dump', to: 'api#dump'
    get '/info', to: 'api#info'
    get '/export', to: 'api#export', defaults: { format: 'text' }
    get '/export_all', to: 'api#export_all', defaults: { format: 'text' }
  end
end
