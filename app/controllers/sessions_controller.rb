class SessionsController < BaseController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      render json: { status: 'ok' }
    else
      render json: { status: 'error', error: 'Wrong login for email and password given' }, status: 403
    end
  end

  def destroy
    log_out if logged_in?
    render json: { message: 'goodbye' }
  end
end
