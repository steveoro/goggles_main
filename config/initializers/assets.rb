# frozen_string_literal: true

# Add additional assets to the asset load path.
# [Steve A.] Remember that for large videos this works better if served outside the assets
# pipeline; for instance, from a CDN or, as a last resort, a /public/videos subfolder
Rails.application.config.assets.paths << Rails.root.join('app/assets/videos')
