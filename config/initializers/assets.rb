# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# [Steve A.] Remember that for large videos this works better if served outside the assets
# pipeline; for instance, from a CDN or, as a last resort, a /public/videos subfolder
Rails.application.config.assets.paths << Rails.root.join('app/assets/videos')

# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

# [Steve A.] (See note above) Also, remember that .m4v videos will be precompiled to .MP4
Rails.application.config.assets.precompile += %w[underwater.m4v]
