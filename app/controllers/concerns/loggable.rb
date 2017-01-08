module Loggable
  extend ActiveSupport::Concern

  def write_started_log
    Rails.logger.info("START #{format_request(request)}")
  end

  def write_finished_log
    Rails.logger.info("FINISH #{format_request(request)}")
  end

  def write_failure_log(message)
    Rails.logger.warn("FAILURE #{format_request(request)}, #{message}")
  end

  def write_information_log(message)
    Rails.logger.info("#{format_request(request)}, #{message}")
  end

  private

  def format_request(request)
    "url: #{request.fullpath}, " + 
    "method: #{request.request_method}, " +
    "action: #{action_name}, " +
    "ip: #{request.remote_ip}"
  end
end
