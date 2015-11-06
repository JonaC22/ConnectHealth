class UsersExistException < StandardError
  def initialize(msg)
    super msg
  end
end
