class SongsController < DashboardController
  include S3Helper

  INSPIRATION_TAGS = [
    "80s synth-pop", "Acoustic ballad", "Epic movie score",
    "Lo-fi hip hop", "Driving rock anthem", "Summer beach vibe"
  ].freeze

  before_action :set_shared_form_data, only: [ :new, :create ]

  def index
  end

  def grid
    sleep 1 if Rails.env.development?
    @songs = Song.processed.order(created_at: :desc).includes(:user, :categories)
  end

  def new
    @song = Song.new
  end

  def create
    @song = Song.new_from_params_and_user(song_params, current_user)

    if @song.save
      GenerateSongJob.perform_later(@song)
      flash.now[:notice] = "Your song is being generated!"

      @new_song = Song.new

    else
      render :new, status: :unprocessable_entity
    end
  end

  def play_url
    song = current_user.songs.find(params[:id])
    song.increment!(:listen_count)
    render json: {
      url: presigned_s3_url(song.s3_key),
      artwork: presigned_s3_url(song.thumbnail_s3_key),
      title: song.title,
      artist: song.user.name
    }
  end

  def toggle_publish
    @song = current_user.songs.find(params[:id])
    @song.update(published: !@song.published)
    render turbo_stream: turbo_stream.replace(
      "song_#{@song.id}_publish_button",
      partial: "songs/publish_button",
      locals: { song: @song }
    )
  end

  def track_list
    song_dom_ids = params.fetch(:song_ids, [])
    song_ids = song_dom_ids.map { |dom_id| dom_id.split("_").last }
    @songs_to_refresh = current_user.songs.where(id: song_ids)
  end

  private

  def song_params
    params.require(:song).permit(
      :full_described_song,
      :instrumental,
      :lyrics,
      :prompt,
      :mode,
      :lyrics_mode
    )
  end

  def set_shared_form_data
    @categories = Category.order(:name)
    @inspiration_tags = INSPIRATION_TAGS
  end
end
