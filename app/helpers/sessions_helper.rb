module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    session[:user_display_name] = user.display_name
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:user_display_name] = user.display_name
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def current_user?(user)
    user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:user_display_name)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    session.delete(:user_display_name)
    @current_user = nil
  end

  def logged_in_user
    fail ForbiddenUserException, 'please log in' unless logged_in?
  end

  def admin_user
    fail ForbiddenUserException, 'must be admin to perform this task' unless current_user.admin?
  end

  def verify_permission(user, permission)
    return if user.admin?
    fail ForbiddenUserException, 'not enough permissions to excecute the task' unless user.roles.joins(:functions).find_by(functions: { description: [permission, 'all'] })
  end

  def authenticate!
    logged_in_user
    verify_permission(current_user, required_permission)
  end

  def required_permission
    'all'
  end
end
