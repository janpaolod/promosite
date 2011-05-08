require 'carrierwave'

CarrierWave.configure do |config|
  if Rails.env.production?

    config.storage = :s3
    config.s3_access_key_id = '189W1YNH4QRV0JD1J7R2'
    config.s3_secret_access_key = 'uVOGHZ4aWj8TZwe34G8fhQs9M2Bj79lZ9WuP6aPN'
    config.s3_bucket = 'filsale-staging'

  elsif Rails.env.development?

    config.storage = :file
    
  else Rails.env.test?

    config.storage = :file
    config.enable_processing = false
    
  end
end