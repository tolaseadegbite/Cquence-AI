class DashboardController < ApplicationController
  layout "dashboard"

  def index
    @songs = Song.processed.order(created_at: :desc).includes(:user)
  end
end
