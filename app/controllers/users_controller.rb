class UsersController < ApplicationController
  def destroy
    user = current_user
    if user.authenticated?(cookies[:remember_token])
      reset_session
      forget(user)
      user.destroy!
      redirect_to root_path, notice: '退会完了しました'
    else
      write_failure_log("authentication failed. #{user.class} id:#{user.id}")
      render file: 'public/400.html', layout: false, content_type: 'text/html',
             status: :unauthorized
    end
  end
end
