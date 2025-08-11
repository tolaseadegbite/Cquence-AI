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

    # 1. Get all the songs, preloading standard associations.
    @songs = Song.processed
                .order(created_at: :desc)
                .includes(:user, :categories)

    # 2. If a user is signed in, efficiently preload their like status.
    if user_signed_in?
      # This creates a hash of { song_id => like_object } in just ONE extra query.
      user_likes = current_user.likes.where(song_id: @songs.map(&:id)).index_by(&:song_id)
      # Attach this preloaded data to each song object in memory.
      @songs.each { |song| song.current_user_like = user_likes[song.id] }
    end
  end

  def new
    @song = Song.new
    @songs = current_user.songs.where.not(status: :processed).order(created_at: :desc)
  end

  def create
    @song = SongCreator.new(song_params, current_user).call

    if @song.save
      GenerateSongJob.perform_later(@song)
      flash.now[:notice] = "Your song is being generated! Scroll down to see the status."
      respond_to do |format|
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @song = Song.includes(:user, :categories).find(params[:id])

    if user_signed_in?
      @song.current_user_like = current_user.likes.find_by(song_id: @song.id)
    end
  end

  def update
    @song = current_user.songs.find(params[:id])
    if @song.update(song_params)
      render turbo_stream: turbo_stream.replace(@song, partial: "songs/track_status", locals: { song: @song })
    else
      render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash", locals: { flash: { alert: "Could not rename song." } })
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
      :title,
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
