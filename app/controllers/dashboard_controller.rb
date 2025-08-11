class DashboardController < ApplicationController
  layout "dashboard"

  def show
  end

  def published_songs
    sleep 1 if Rails.env.development?

    @songs = Song.where(published: true).processed.order(created_at: :desc).includes(:user).includes(likes: :user)
  end
end
