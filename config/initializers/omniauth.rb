OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  provider :paypal, ENV['GAUGE_PAYPAL_ID'], ENV['GAUGE_PAYPAL_TOKEN'], {:scope => "https://identity.x.com/xidentity/resources/profile/me"}
end
