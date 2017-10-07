class SessionsController < ApplicationController
  def create
    user = create_user_corresponding_to_request
    if user.errors.any?
      redirect_to root_path, alert: user.errors.full_messages
      return
    end

    log_in(user)
    redirect_to root_path
  end

  def destroy
    log_out
    redirect_to root_path, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_path, alert: ['認証に失敗しました']
  end

  private

  def create_user_corresponding_to_request
    if (auth_hash = request.env['omniauth.auth'])
      User.find_or_create_from_auth_hash(auth_hash)
    elsif (username = params[:user][:username])
      User.create(username: username, guest_user: GuestUser.new)
    end
  end
end
