class SongsController < DashboardController
  include S3Helper

  INSPIRATION_TAGS = [
    "80s synth-pop", "Acoustic ballad", "Epic movie score",
    "Lo-fi hip hop", "Driving rock anthem", "Summer beach vibe"
  ].freeze

  def index
    @songs = Song.processed.order(created_at: :desc).includes(:user, :categories)
  end

  def new
    @song = Song.new
    @categories = Category.order(:name)
    @inspiration_tags = INSPIRATION_TAGS
    # @user_songs = current_user.songs.order(created_at: :desc)
  end

  def create
    mode = params.require(:song).fetch(:mode)
    lyrics_mode = params.require(:song).fetch(:lyrics_mode)
    permitted_params = song_params
    attributes = build_song_attributes(permitted_params, mode, lyrics_mode)
    title = generate_title_from_params(permitted_params, mode, lyrics_mode)

    @song = current_user.songs.new(attributes.merge(title: title, status: :pending))

    if @song.save
      GenerateSongJob.perform_later(@song)
      flash.now[:notice] = "Your song is being generated!"

      @new_song = Song.new

      @categories = Category.order(:name)
      @inspiration_tags = INSPIRATION_TAGS
    else
      @categories = Category.order(:name)
      @inspiration_tags = INSPIRATION_TAGS
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

  private

  def song_params
    params.require(:song).permit(
      :full_described_song,
      :instrumental,
      :lyrics,
      :prompt
    )
  end

  def build_song_attributes(params, mode, lyrics_mode)
    if mode == "simple"
      params.slice(:full_described_song, :instrumental)
    else # Custom mode
      if lyrics_mode == "write"
        params.slice(:prompt, :lyrics, :instrumental)
      else # Auto-lyrics mode
        params.slice(:prompt, :instrumental).merge(described_lyrics: params[:lyrics])
      end
    end
  end

  # Generates a clean, capitalized title from the most relevant user input.
  def generate_title_from_params(params, mode, lyrics_mode)
    source_text = "Untitled Song"

    if mode == "simple" && params[:full_described_song].present?
      source_text = params[:full_described_song]
    elsif mode == "custom" && lyrics_mode == "auto" && params[:lyrics].present?
      source_text = params[:lyrics]
    elsif mode == "custom" && params[:prompt].present?
      source_text = params[:prompt]
    end

    source_text.truncate(100).capitalize
  end
end
