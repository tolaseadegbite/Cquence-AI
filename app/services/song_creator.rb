class SongCreator
  def initialize(params, user)
    @params = params
    @user = user
    @mode = params.fetch(:mode)
    @lyrics_mode = params.fetch(:lyrics_mode)
  end

  def call
    attributes = build_song_attributes
    title = generate_title

    new_song = @user.songs.new(attributes.merge(title: title, status: :pending))
    new_song.mode = @mode
    new_song.lyrics_mode = @lyrics_mode
    new_song
  end

  private

  def build_song_attributes
    if @mode == "simple"
      @params.slice(:full_described_song, :instrumental)
    else # Custom mode
      if @lyrics_mode == "write"
        # In "Write" mode, save the text to the `lyrics` column.
        @params.slice(:prompt, :lyrics, :instrumental)
      else # "Auto" lyrics mode
        # In "Auto" mode, save the text to the `described_lyrics` column.
        @params.slice(:prompt, :instrumental).merge(described_lyrics: @params[:lyrics])
      end
    end
  end

  def generate_title
    source_text = "Untitled Song"
    if @mode == "simple" && @params[:full_described_song].present?
      source_text = @params[:full_described_song]
    elsif @mode == "custom" && @lyrics_mode == "auto" && @params[:lyrics].present?
      source_text = @params[:lyrics] # The text from the form is used for the title
    elsif @mode == "custom" && @params[:prompt].present?
      source_text = @params[:prompt]
    end
    source_text.truncate(100).capitalize
  end
end
