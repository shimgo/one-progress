class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include Loggable

  before_action :write_started_log
  after_action :write_finished_log

  def authenticate
    redirect_to root_path, alert: ['ログインしてください'] unless logged_in?
  end
end
