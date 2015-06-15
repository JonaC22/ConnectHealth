class Resultado
  attr_accessor :desc,:err_number
  def initialize(desc,err_number)
    @desc=desc
    @err_number = err_number
  end
end