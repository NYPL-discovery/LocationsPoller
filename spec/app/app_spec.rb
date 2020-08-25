require 'spec_helper'
require_relative '../../app.rb'
require_relative './expected_mappings'

p 'directory: ', Dir.pwd

$mock_logger = MockLogger.new
$mock_s3 = MockS3.new
$mock_bucket = MockBucket.new
$mock_object = MockObject.new
$mock_event = MockEvent.new
$mock_uri = MockURI.new
$mock_http = MockHTTP.new
http_response_path = File.expand_path('./mock_response.txt', __dir__)
$http_response = File.readlines(http_response_path).join
$expected_mappings = expected_mappings

describe 'init' do
  before do
    ENV['LOG_LEVEL'] = 'MOCK_LEVEL'
    ENV['S3_BUCKET'] = 'MOCK_S3_BUCKET'
    ENV['S3_OBJECT'] = 'MOCK_S3_OBJECT'
    allow(NYPLRubyUtil::NyplLogFormatter).to receive(:new).and_return($mock_logger)
    allow(Aws::S3::Resource).to receive(:new).and_return($mock_s3)
    allow($mock_s3).to receive(:bucket).and_return($mock_bucket)
    allow($mock_bucket).to receive(:object).and_return($mock_object)
  end
  it 'should set logger' do
    expect(NYPLRubyUtil::NyplLogFormatter).to receive(:new).with(STDOUT, {level: 'MOCK_LEVEL'})
    init
    expect($logger).to eq($mock_logger)
  end
  it 'should set locations_object' do
    expect(Aws::S3::Resource).to receive(:new).with({ region: 'us-east-1' })
    expect($mock_s3).to receive(:bucket).with('MOCK_S3_BUCKET')
    expect($mock_bucket).to receive(:object).with('MOCK_S3_OBJECT')
    init
    expect($locations_object).to eq($mock_object)
  end
end

describe 'handle_event' do

  before do
    allow(NYPLRubyUtil::NyplLogFormatter).to receive(:new).and_return($mock_logger)
    allow(Aws::S3::Resource).to receive(:new).and_return($mock_s3)
    allow($mock_s3).to receive(:bucket).and_return($mock_bucket)
    allow($mock_bucket).to receive(:object).and_return($mock_object)
    allow($mock_logger).to receive(:info).and_return('')
    ENV['SIERRA_URL'] = 'MOCK_SIERRA_URL'
    allow(URI).to receive(:parse).and_return('MOCK_URI')
    allow($mock_logger).to receive(:info).and_return('')
    allow($locations_object).to receive(:put).and_return(nil)
    allow(Net::HTTP).to receive(:get).and_return($http_response)
  end

  it 'should call init' do
    expect(self).to receive(:init)
    handle_event(event: nil, context: nil)
  end

  it 'should log event' do
    expect($mock_logger).to receive(:info).with('handling event: ', $mock_event)
    handle_event(event: $mock_event, context: nil)
  end

  it 'should make correct HTTP request' do
    expect(URI).to receive(:parse).with('MOCK_SIERRA_URL')
    expect(Net::HTTP).to receive(:get).with('MOCK_URI')
    handle_event(event: $mock_event, context: nil)
  end

  it 'should log mappings' do
    expect($mock_logger).to receive(:info).with("putting: ", $expected_mappings)
    handle_event(event: $mock_event, context: nil)
  end

  it 'should put mappings to s3' do
    expect($mock_object).to receive(:put).with({body: $expected_mappings.to_json})
    handle_event(event: $mock_event, context: nil)
  end
end
