require "grape-swagger"
require "grape_logging" unless Rails.env.test?

module V1
  class Base < Grape::API

    use GrapeLogging::Middleware::RequestLogger, {logger: logger} unless Rails.env.test?

    http_basic do |email, password|
      dev_log email
      dev_log password
      @current_user = User.find_by_email(email)
      @current_user && @current_user.valid_password?(password)
    end

    helpers do
      def current_user
        @current_user
      end
    end

    content_type   :json, 'application/json'
    default_format :json

    mount V1::Users
    mount V1::Trackers
    mount V1::Issues
    mount V1::Offers
    mount V1::Contracts
    mount V1::Positions
    mount V1::Events
    mount V1::Host

    add_swagger_documentation(
        api_version: "v1"       ,
        mount_path:  "/docs"    ,
        base_path:   "/api/v1"  ,
        security_definitions: {
          base: {type: "basic"}
        },
        security:    [{base: []}],
        info: {
          title:        "Bugmark API"                                 ,
          description:  "all calls require BASIC AUTH"                ,
          contact_name: "Andrew Leak - andy@r210.com - 650-823-0836"  ,
        }
      )
  end
end
