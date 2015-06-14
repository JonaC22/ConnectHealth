class BaseController < ApplicationController
# include ActionController::Serialization # sirve para decirle que es lo que se va a usar cuando devuelva el json
  before_filter :parse_request

    def parse_request

    end

end
