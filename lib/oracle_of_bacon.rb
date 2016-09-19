#require 'byebug'                # optional, may be helpful
require 'open-uri'              # allows open('http://...') to return body
require 'cgi'                   # for escaping URIs
require 'nokogiri'              # XML parser
require 'active_model'          # for validations

class OracleOfBacon

  class InvalidError < RuntimeError ; end
  class NetworkError < RuntimeError ; end
  class InvalidKeyError < RuntimeError ; end

  attr_accessor :from, :to
  attr_reader :api_key, :response, :uri
  
  include ActiveModel::Validations
  validates_presence_of :from
  validates_presence_of :to
  validates_presence_of :api_key
  validate :from_does_not_equal_to

  def from_does_not_equal_to
    if @from == @to
      self.errors.add(:from, 'cannot be the same as To')
    end
  end

  def initialize(api_key='')
    @api_key = api_key
    @to = "Kevin Bacon"
    @from = "Kevin Bacon"
  end

  def find_connections
    make_uri_from_arguments
    begin
      xml = URI.parse(uri).read
    rescue OpenURI::HTTPError 
      xml = %q{<?xml version="1.0" standalone="no"?>
<error type="unauthorized">unauthorized use of xml interface</error>}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
      Net::ProtocolError => e
      # convert all of these into a generic OracleOfBacon::NetworkError,
      #  but keep the original error message
      # your code here
      raise NetworkError, e.to_s
    end
    # your code here: create the OracleOfBacon::Response object
  end

  def make_uri_from_arguments
    # your code here: set the @uri attribute to properly-escaped URI
    # constructed from the @from, @to, @api_key arguments
  end
      
  class Response
    attr_reader :type, :data

    def initialize(xml)
      @doc = Nokogiri::XML(xml)
      parse_response
    end

    private

    def parse_response
      if ! @doc.xpath('/error').empty?
        parse_error_response
      elsif ! @doc.xpath('/spellcheck').empty?
        parse_spellcheck_response
      elsif ! @doc.xpath('/link').empty?
        parse_graph_response
      else
        parse_error_response
      end
    end

    def parse_error_response
     #Your code here.  Assign @type and @data
     # based on type attribute and body of the error element
     if @doc.xpath
    end

    def parse_spellcheck_response
      @type = :spellcheck
      @data = @doc.xpath('//match').map(&:text)
      #Note: map(&:text) is same as map{|n| n.text}
    end

    def parse_graph_response
      #Your code here
    end

    def parse_unknown_response
      @type = :unknown
      @data = 'Unknown response type'
    end
  end
end

