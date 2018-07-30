class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  after_action :set_last_seen, if: proc { user_signed_in? }

  def after_sign_in_path_for(user)
    user.update_attribute(:last_session_ended_at, user.last_seen_at)
    user.reload
    xloc = stored_location_for(user)
    if is_base_login?(xloc) && has_new_events?(user)
      "/docfix/new_events"
    else
      xloc
    end
  end

  def after_sign_out_path_for(_resource)
    "/docfix"
  end

  private

  def is_base_login?(xloc)
    xloc == "/docfix/new_login"
  end

  def has_new_events?(user)
    return false if [user.last_event_at, user.last_seen_at].any? {|x| x.blank?}
    user.last_event_at > user.last_seen_at
  end

  def set_last_seen
    current_user.update_attribute(:last_seen_at, Time.now)
  end
end
