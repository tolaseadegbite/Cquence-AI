class DashboardController < ApplicationController
  include S3Helper

  def show
  end

  def published_songs
    @songs = Song.where(published: true)
                 .processed
                 .order(created_at: :desc)
                 .includes(:user)

    # --- HTTP CACHING ---
    # This remains the same. It's our first, fast line of defense.
    fresh_when @songs

    # NOTE: If you need to show like counts or the current user's like status on this page,
    # you would add the same efficient `likes` pre-loading logic here as we did in the
    # SongsController#grid action. For now, we will proceed without it.

    # ==========================================================
    # FINAL OPTIMIZATION: Use fetch_multi to avoid N+1 cache queries
    # ==========================================================

    # Build an array of the cache keys we need.
    cache_keys = @songs.map { |s| [ s, "presigned_urls" ] }

    # `fetch_multi` will yield the *key* on a cache miss.
    # We destructure the key `[song, _]` to get the song object.
    cached_urls = Rails.cache.fetch_multi(*cache_keys, expires_in: 50.minutes) do |key|
      song = key.first # Extract the song object from the key array

      # This block now correctly operates on the `song` object.
      {
        audio_url: presigned_s3_url(song.s3_key),
        thumbnail_url: presigned_s3_url(song.thumbnail_s3_key)
      }
    end

    # Assign the retrieved URLs back to the song objects.
    @songs.each do |song|
      # Use the same key structure to look up the result in the hash.
      urls = cached_urls[[ song, "presigned_urls" ]]
      if urls
        song.presigned_audio_url = urls[:audio_url]
        song.presigned_thumbnail_url = urls[:thumbnail_url]
      end
    end
  end
end
