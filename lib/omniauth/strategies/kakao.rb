require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Kakao < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://kauth.kakao.com',
        :authorize_path => '/oauth/authorize',
        :token_url => '/oauth/token',
      }

      uid { raw_info['id'].to_s }

      info do
        {
	  email: raw_info.dig(:kakao_acount, :email)
        }
      end

      extra do
        {'properties' => raw_properties}
      end

      def callback_url
	 full_host + callback_path
      end

      def initialize(app, *args, &block)
        super
        options[:callback_path] = options[:redirect_path] 
      end

      def callback_phase
        previous_callback_path = options.delete(:callback_path)
        @env["PATH_INFO"] = "/users/auth/kakao/callback"
        options[:callback_path] = previous_callback_path
        super
      end

      def mock_call!(*)
        options.delete(:callback_path)
        super
      end

    private
      def raw_info
        @raw_info ||= access_token.get('https://kapi.kakao.com/v2/user/me', {}).parsed || {}
      end

      def raw_properties
        @raw_properties ||= raw_info['properties']
      end
    end
  end
end

OmniAuth.config.add_camelization 'kakao', 'Kakao'
