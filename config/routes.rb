Rails.application.routes.draw do
  resources :widgets

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  root 'welcome#index'

  scope '/api' do
    resources :pedigrees, only: [:index, :show, :create, :update, :destroy]
    resources :patients, only: [:index, :show, :create, :update, :destroy]
    resources :make_pedigrees, only: [:index]
    resources :model_calculator, only: [:index, :show]
    scope '/pedigrees' do
      get '/query' => 'pedigree#query'
      get '/medicos' => 'pedigree#get_medicos_mysql'
      get '/pacientes' => 'pedigree#get_pacientes_mysql'
    end
    scope '/statistics' do
      get '/' => 'statistics#index'
      post '/query' => 'statistics#get_results'
      get '/reports' => 'statistics#get_reports'
    end
    get '/createGraphDB' => 'generate_graph_db#generate'
    get '/flushGraphDB' => 'pedigree#delete_all_nodes'
    get '/createGraphDBTest' => 'generate_graph_db#generate'
  end
  # Esto es para el comienzo de la api *path es "cualquier otro que no este expresado arriba"
  post '/', to: 'welcome#delete_paciente'
  get '/pacientes', to: 'welcome#pacientes'
  post '/pacientes', to: 'welcome#insert_paciente'
  get '*path', to: 'base#routing_error'
  delete '*path', to: 'base#routing_error'
  post '*path', to: 'base#routing_error'
  put '*path', to: 'base#routing_error'
  patch '*path', to: 'base#routing_error'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
