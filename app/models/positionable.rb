# TODO eliminar este modulo y todo lo relacionado (base de datos, etc)
module Positionable
  extend ActiveSupport::Concern
  attr_accessor :pos_x, :pos_y
end
