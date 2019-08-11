require 'dnsimple'

module Letsencrypt
  module Dnsimple
    LETSENCRYPT_NAME = "_acme-challenge".freeze # paranoid, don't use value from acme client
    LETSENCRYPT_NAME_TYPE = "TXT".freeze # paranoid, don't use value from acme client

    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def self.available?
      configuration.valid?
    end

    def self.update_auth_record auth
      begin
        challenge = auth.dns
        raise "acme is not allowing DNS authentication" unless challenge
        raise "acme wanted record name #{challenge.record_name}, expected #{LETSENCRYPT_NAME}" unless challenge.record_name == LETSENCRYPT_NAME
        raise "acme wanted record type #{challenge.record_type}, expected #{LETSENCRYPT_NAME_TYPE}" unless challenge.record_type == LETSENCRYPT_NAME_TYPE

        client = Dnsimple::Client.new access_token:configuration.access_token
        account_id = client.identity.whoami.data.account.id
        record = client.zones.all_zone_records(account_id, auth.domain, filter:{name:challenge.record_name, type:challenge.record_type})

        if record.data.count > 0
          if record.data.first.content == challenge.record_content
            puts "Existing record already has the challenge value - all good here"
          else
            puts "Updating existing record"
            client.zones.update_zone_record(account_id, auth.domain, record.data.first.id, content:challenge.record_content)
          end
        else
          puts "Adding record with challenge value"
          client.zones.create_zone_record(account_id, auth.domain, name:challenge.record_name, type:challenge.record_type, content:challenge.record_content)
        end

        true
      rescue => e
        puts e.message
        false
      end
    end

    class Configuration
      attr_accessor :access_token

      def initialize
        @access_token = ENV["DNSIMPLE_ACCESS_TOKEN"]
      end

      def valid?
        access_token
      end
    end
  end
end
