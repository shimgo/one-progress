Rails.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log", 'daily')
Rails.logger.formatter = proc do |severity, datetime, progname, msg|
  "[#{severity}] #{datetime}: #{progname} : #{msg}\n" if msg.present?
end
