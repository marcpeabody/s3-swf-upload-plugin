require 'base64'

class S3UploadsController < ApplicationController

  # The plugin flash script has to be able to access this controller, so don't block it with authentication!
  # You can delete the following line if you have no authentication in your app.

  #skip_before_filter  :<*** your authentication filter, if any, goes here!>, [:only => "index"]

  # --- no code for modification below here ---

  # Sigh.  OK that's not completely true - you might want to look at https and expiration_date below.
  #        Possibly these should also be configurable from S3Config...

  skip_before_filter :verify_authenticity_token
  include S3SwfUpload::Signature
  
  def index
    
    settings        = []
    bucket          = S3SwfUpload::S3Config.bucket
    access_key_id   = S3SwfUpload::S3Config.access_key_id
    acl             = S3SwfUpload::S3Config.acl
    https           = 'false'

    max_file_size = S3SwfUpload::S3Config.max_file_size
    max_file_MB   = (max_file_size/1024/1024).to_i
    expiration_date = 1.hours.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')

    params[:do_checks].keys.each do |k|
      key             = params[:key][k]
      content_type    = params[:content_type][k]
      file_size       = params[:file_size][k]
      
      error_message   = "Selected file is too large (max is #{max_file_size}MB)" if file_size.to_i >  S3SwfUpload::S3Config.max_file_size

      if params[:do_checks][k] == "1"
        error_message = self.s3_swf_upload_file_error?(key) 
      end

      policy_params = "{
      'expiration': '#{expiration_date}',
      'conditions': [
          {'bucket': '#{bucket}'},
          {'key': '#{key}'},
          {'acl': '#{acl}'},
          {'Content-Type': '#{content_type}'},
          ['starts-with', '$Filename', ''],
          ['eq', '$success_action_status', '201']
      ]
}"

      policy = Base64.encode64(policy_params).gsub(/\n|\r/, '')

      signature = b64_hmac_sha1(S3SwfUpload::S3Config.secret_access_key, policy)

      settings.push({
        :fileindex       => k,
        :key             => key,
        :policy          => policy,
        :signature       => signature,
        :bucket          => bucket,
        :accesskeyid     => access_key_id,
        :acl             => acl,
        :expirationdate  => expiration_date,
        :https           => https,
        :errorMessage   => error_message.to_s })
    end


    respond_to do |format|
      format.xml {
        logger.debug{ settings.inspect }
        render :xml => settings.to_xml
      }
    end
  end
end
