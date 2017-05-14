module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    remember(user)
  end

  def log_out
    return unless logged_in?

    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def current_user
    user_id_in_cookies = cookies.signed[:user_id]
    user_id_in_session = session[:user_id]

    raise <<-EOS.strip_heredoc if user_id_in_cookies.nil? && user_id_in_session
      cookieのユーザIDがnilの場合はセッションのユーザIDもnilである必要があります。\n
      (session[:user_id]: #{user_id_in_session})
    EOS

    if user_id_in_session
      @current_user ||= User.find_by(id: user_id_in_session)
    elsif user_id_in_cookies
      @current_user ||= authenticated_user(user_id_in_cookies)
    end
  end

  def logged_in?
    !current_user.nil?
  end

  private

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def authenticated_user(user_id)
    user = User.find_by(id: user_id)
    return unless user && user.authenticated?(cookies[:remember_token])

    log_in(user)
    user
  end
end
