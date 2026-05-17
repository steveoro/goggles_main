# frozen_string_literal: true

# Base controller for admin-only jobs dashboard
class JobsDashboardBaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_jobs_dashboard!

  private

  def authorize_jobs_dashboard!
    redirect_to(root_path) unless GogglesDb::GrantChecker.admin?(current_user)
  end
end
