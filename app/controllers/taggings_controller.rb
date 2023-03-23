# frozen_string_literal: true

# = TaggingsController customizations
#
class TaggingsController < ApplicationController
  before_action :authenticate_user!, :validate_ajax_request_and_meeting_id
  before_action :validate_team_id, :prepare_managed_teams, only: :by_team

  # XHR POST /by_user/:meeting_id
  # Tags/Untags the specified Meeting ID as "starred" by the current_user.
  # Requires authentication.
  #
  def by_user
    logger.info("\r\n---> Taggings#by_user(User: #{current_user.id}, Meeting: #{tag_params[:meeting_id]})")
    already_starred = @meeting.tags_by_user_list.include?("u#{current_user.id}")
    action = already_starred ? :remove : :add

    @meeting.tags_by_user_list.send(action, "u#{current_user.id}")
    @saved_ok = @meeting.save
    logger.info("---> Tag #{already_starred ? 'OFF' : 'ON'}") && return if @saved_ok

    flash[:error] = I18n.t('tags.error_during_save')
  end

  # XHR POST /by_team(:team_id, :meeting_id)
  # Tags/Untags the specified Meeting ID as "starred" by the current_user for the specific Team ID.
  # Requires authentication.
  #
  def by_team
    logger.info("\r\n---> Taggings#by_team(Team: #{tag_params[:team_id]}, Meeting: #{tag_params[:meeting_id]})")
    already_starred = @meeting.tags_by_team_list.include?("t#{tag_params[:team_id]}")
    action = already_starred ? :remove : :add

    @meeting.tags_by_team_list.send(action, "t#{tag_params[:team_id]}")
    @saved_ok = @meeting.save
    logger.info("---> Tag #{already_starred ? 'OFF' : 'ON'}") && return if @saved_ok

    flash[:error] = I18n.t('tags.error_during_save')
  end

  private

  # Strong parameters checking for all taggings operations
  def tag_params
    params.permit(:meeting_id, :team_id)
  end

  # Validates request type and the required meeting_id parameter.
  # Sets the internal <tt>@meeting</tt> member when valid.
  # Redirects to root_path otherwise.
  def validate_ajax_request_and_meeting_id
    unless request.xhr? && request.post? && tag_params[:meeting_id].present? &&
           GogglesDb::Meeting.exists?(tag_params[:meeting_id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @meeting = GogglesDb::Meeting.find_by(id: tag_params[:meeting_id])
  end

  # Validates the required team_id parameter
  # Sets the internal <tt>@team</tt> member when valid.
  # Redirects to root_path otherwise.
  def validate_team_id
    unless tag_params[:team_id].present? && GogglesDb::Team.exists?(tag_params[:team_id])
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end

    @team = GogglesDb::Team.find_by(id: tag_params[:team_id])
  end
end
