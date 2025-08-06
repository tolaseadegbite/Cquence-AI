class SongsController < ApplicationController
  before_action :authenticate_user! # Assuming you have user authentication

  def create
    # Create the song record with user input
    @song = current_user.songs.new(song_params)

    if @song.save
      # Enqueue the job to be run in the background.
      GenerateSongJob.perform_later(@song)
      # Redirect the user to a page where they can see the song's status.
      redirect_to @song, notice: "Your song is being generated! It may take a few minutes."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def song_params
    # Be sure to permit all the fields from the form
    params.require(:song).permit(
      :title, :prompt, :lyrics, :full_described_song, :described_lyrics,
      :guidance_scale, :infer_step, :audio_duration, :seed, :instrumental
    )
  end
end
