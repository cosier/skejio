# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
  business/main.css
  settings/main.js
  settings/main.css
  simulator/main.js
  simulator/main.css
  super/main.css
  super/manage_businesses.css
)

if Rails.env.development?
  Rails.application.config.assets.precompile += %w( dev.css dev.js)
end
