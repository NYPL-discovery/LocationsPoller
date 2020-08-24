require 'nypl_ruby_util'
require 'net/http'
require 'aws-sdk-s3'

def init
  $logger = NYPLRubyUtil::NyplLogFormatter.new(STDOUT, level: ENV['LOG_LEVEL'])
  credentials = { region: 'us-east-1' }
  s3 = Aws::S3::Resource.new(credentials)
  $locations_object = s3.bucket(ENV['S3_BUCKET']).object(ENV['S3_OBJECT'])
end

def handle_event(event:, context:)
  init
  $logger.info("handling event: ", event)

  mappings = Net::HTTP.get(URI.parse(ENV['SIERRA_URL']))
    .scan(/(#\s*)?LOC_([^=]+)=([^\s]+)/)
    .map {|(commented, code, url)| commented ? [/.\A/, ''] : [code, url]}
    .to_h

  $logger.info("putting: ", mappings)

  $locations_object.put(body: mappings.to_json)
end
