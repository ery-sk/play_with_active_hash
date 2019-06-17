Rails.application.config.to_prepare do
  Prefecture.data = [
    { name: '北海道' },
    { name: '青森県' }
  ]
end
