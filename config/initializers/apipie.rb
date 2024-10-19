Apipie.configure do |config|
  config.app_name                = "Blog"
  config.api_base_url            = nil
  config.doc_base_url            = "/apipie"
  config.validate = false
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
