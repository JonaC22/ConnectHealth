class PatientsExistException < StandardError
  def initialize(msg)
    super msg
  end
end
