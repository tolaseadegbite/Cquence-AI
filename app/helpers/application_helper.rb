require "aws-sdk-s3"

module ApplicationHelper
  # returns full title if present, else returns base title
  def full_title(page_title = "")
    base_title = "CQuence AI"
    if page_title.blank?
        base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # This helper generates a secure, temporary URL for a private S3 object.
  # It reads credentials directly from Rails' encrypted credentials file.
  def s3_presigned_url(key, expires_in_seconds: 3600) # Default: 1 hour
    return "" if key.blank? # Return empty string if the key is nil or empty

    # Memoize the presigner object to avoid re-creating it on every call.
    @s3_presigner ||= Aws::S3::Presigner.new(
      client: Aws::S3::Client.new(
        # --- THESE KEYS NOW EXACTLY MATCH YOUR CREDENTIALS FILE ---
        region:            Rails.application.credentials.aws[:region],
        access_key_id:     Rails.application.credentials.aws[:access_key_id],
        secret_access_key: Rails.application.credentials.aws[:secret_access_key]
      )
    )

    # Generate the presigned URL for the given key in your bucket.
    @s3_presigner.presigned_url(
      :get_object,
      bucket: Rails.application.credentials.aws[:s3_bucket_name],
      key: key,
      expires_in: expires_in_seconds
    )
  rescue StandardError => e
    # Log the error and return an empty string so the page doesn't crash
    # if credentials are misconfigured or there's a network issue.
    Rails.logger.error "S3 Presigned URL generation failed: #{e.message}"
    ""
  end
end
