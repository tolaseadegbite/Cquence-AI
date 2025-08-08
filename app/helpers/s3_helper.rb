# app/helpers/s3_helper.rb
module S3Helper
  # Generates a temporary, secure URL for a private object in S3.
  def presigned_s3_url(key, expires_in: 3600)
    return nil if key.blank?

    presigner = s3_presigner
    bucket_name = Rails.application.credentials.aws[:s3_bucket_name]

    presigner.presigned_url(:get_object, bucket: bucket_name, key: key, expires_in: expires_in)
  end

  private

  # Memoizes the S3 presigner client to be more efficient.
  def s3_presigner
    @s3_presigner ||= begin
      aws_creds = Rails.application.credentials.aws

      # Create an S3 client and explicitly provide BOTH the region AND the credentials.
      s3_client = Aws::S3::Client.new(
        region:            aws_creds[:region],
        access_key_id:     aws_creds[:access_key_id],
        secret_access_key: aws_creds[:secret_access_key]
      )

      Aws::S3::Presigner.new(client: s3_client)
    end
  end
end
