class SessionsController < ApplicationController
  def create
    if request.env['omniauth.auth']
      user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    elsif params[:user][:username]
      user = User.new(username: params[:user][:username])
      user.guest_user = GuestUser.new
      unless user.save
        redirect_to root_path, alert: user.errors.full_messages
        return
      end
    end

    log_in(user)

    redirect_to root_path
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
