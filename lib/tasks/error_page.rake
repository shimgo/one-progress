namespace :error_page do
  desc 'generate error pages'
  task gen: :environment do
    re = /^error_(\d+)$/
    ErrorsController.instance_methods.map(&:to_s).select{|m|m =~ re}.each do |action|
      code = action[re, 1]
      fpath = Rails.root.join('public', "#{code}.html")
      html  = ErrorsController.render(action).gsub(/^\s*<meta name="csrf-token".+$/, "")

      File.write(fpath, html)
    end
  end
end
