class SessionsController < ApplicationController
  def create
    if request.env['omniauth.auth']
      user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    elsif params[:session][:username]
      user = User.new(username: params[:session][:username])
      user.guest_user = GuestUser.new
      user.save!
    end

    log_in(user)

    redirect_to root_path
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
