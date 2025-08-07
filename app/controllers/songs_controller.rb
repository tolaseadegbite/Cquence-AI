class SongsController < DashboardController
  # Assuming you have a filter like `before_action :authenticate_user!` active from your DashboardController

  INSPIRATION_TAGS = [
    "80s synth-pop", "Acoustic ballad", "Epic movie score",
    "Lo-fi hip hop", "Driving rock anthem", "Summer beach vibe"
  ].freeze

  def index
    @songs = Song.processed.order(created_at: :desc).includes(:user, :categories)
  end

  # Displays the form for creating a new song
  def new
    @song = Song.new
    @categories = Category.order(:name)
    @inspiration_tags = INSPIRATION_TAGS
  end

  # Handles the submission of the new song form
  def create
    # 1. Read the non-model parameters to determine the user's intent.
    mode = params.require(:song).fetch(:mode)
    lyrics_mode = params.require(:song).fetch(:lyrics_mode)

    # 2. Get the hash of attributes that are safe to be saved to the database.
    permitted_params = song_params

    # 3. Build the final hash of attributes for the new Song record based on the mode.
    attributes = if mode == "simple"
      permitted_params.slice(:full_described_song, :instrumental)
    else # Custom mode
      if lyrics_mode == "write"
        permitted_params.slice(:prompt, :lyrics, :instrumental)
      else # Auto-lyrics mode (maps the form's 'lyrics' field to the DB's 'described_lyrics' column)
        permitted_params.slice(:prompt, :instrumental).merge(described_lyrics: permitted_params[:lyrics])
      end
    end

    # 4. Generate a meaningful title from the user's input.
    title = generate_title_from_params(permitted_params, mode, lyrics_mode)

    # 5. Create the new song object with the correct attributes and the generated title.
    @song = current_user.songs.new(attributes.merge(title: title))

    if @song.save
      GenerateSongJob.perform_later(@song)
      redirect_to root_path, notice: "Your song is being generated! You'll be notified when it's ready."
    else
      # If validations fail, re-load the necessary instance variables for the form.
      @categories = Category.order(:name)
      @inspiration_tags = INSPIRATION_TAGS
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Defines the "allow-list" of attributes that can be mass-assigned from the form.
  # These are only attributes that exist as columns in the `songs` table.
  def song_params
    params.require(:song).permit(
      :full_described_song,
      :instrumental,
      :lyrics,
      :prompt
    )
  end

  # Generates a clean, capitalized title from the most relevant user input.
  # This mirrors the logic from the original JavaScript implementation.
  def generate_title_from_params(params, mode, lyrics_mode)
    source_text = "Untitled Song" # Default fallback title

    if mode == "simple" && params[:full_described_song].present?
      source_text = params[:full_described_song]
    elsif mode == "custom" && lyrics_mode == "auto" && params[:lyrics].present?
      # In 'auto' mode, the 'lyrics' param holds the description of the lyrics.
      source_text = params[:lyrics]
    elsif mode == "custom" && params[:prompt].present?
      # As a fallback in custom mode, use the prompt/style.
      source_text = params[:prompt]
    end

    # Clean up, truncate to a safe length, and capitalize the title.
    source_text.truncate(100).capitalize
  end
end
