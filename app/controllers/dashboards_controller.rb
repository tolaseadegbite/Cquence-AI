class DashboardsController < ApplicationController
  include S3Helper

  before_action :authenticate

  def show
    @songs = Song.where(published: true)
                 .processed
                 .order(created_at: :desc)
                 .includes(:user)
  end
end
