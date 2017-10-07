def generate_error_page
  rake = Rake::Application.new
  Rake.application = rake
  Rake.application.rake_require("error_page", ["#{Rails.root}/lib/tasks"])
  Rake::Task.define_task(:environment)
  rake["error_page:gen"].execute
end
