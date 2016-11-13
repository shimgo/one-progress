class UsersController < ApplicationController
  def destroy
    user = current_user
    if user.authenticated?(cookies[:remember_token])
      reset_session
      forget(user)
      user.destroy!
      redirect_to root_path, notice: '退会完了しました'
    else
      raise '認証に失敗しました'
    end
  end
end
