module SpreadsheetImporter
  module Session
    module ModuleMethods
      def auth
        check!

        @auth ||= authorization.tap do |authorization|
          params.each { |k, v| authorization.send("#{k}=", v) }
        end
      end

      def check!
        fail(
          NotImplementedError,
          'ENV["GOOGLE_CLIENT_ID"] is nil'
        ) if ENV['GOOGLE_CLIENT_ID'].nil?

        fail(
          NotImplementedError,
          'ENV["GOOGLE_CLIENT_SECRET"] is nil'
        ) if ENV['GOOGLE_CLIENT_SECRET'].nil?
      end

      def params
        {
          client_id: ENV['GOOGLE_CLIENT_ID'],
          client_secret: ENV['GOOGLE_CLIENT_SECRET'],
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          scope: 'https://www.googleapis.com/auth/drive ' + 'https://spreadsheets.google.com/feeds/'
        }
      end

      def client
        ::Google::APIClient.new(
            application_name: ENV['APPLICATION_NAME'],
            application_version: ENV['APPLICATION_VERSION']
        )
      end

      def authorization
        @authorization ||= client.authorization
      end

      def refresh_token
        refresh_message
        auth.code = STDIN.gets.chomp
        auth.fetch_access_token!
        refreshed_message
      end

      def refresh_message
        STDOUT.puts("1. Open this page:\n#{auth.authorization_uri}\n\n")
        STDOUT.puts('2. Enter the authorization code shown in the page: ')
      end

      def refreshed_message
        STDOUT.puts "環境変数GOOGLE_REFRESH_TOKENに #{auth.refresh_token} をセットしてください"
        ::Kernel.exit
      end
    end

    extend ModuleMethods
  end
end
