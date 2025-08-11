class LikesController < ApplicationController
  # before_action :authenticate
  before_action :set_song, only: [ :create ]
  before_action :set_like, only: [ :destroy ]

  def create
    @like = current_user.likes.new(song: @song)

    if @like.save
      @song.current_user_like = @like

      respond_to do |format|
        format.turbo_stream
      end
    else
      redirect_to @song, alert: "Could not like this song."
    end
  end

  def destroy
    @song = @like.song
    @like.destroy

    @song.current_user_like = nil

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def set_like
    @like = current_user.likes.find(params[:id])
  end
end
