require "rack/disable_css_animations/version"

module Rack
  class DisableCSSAnimations
    if defined?(Rails)
      class Rails < Rails::Railtie
        initializer "rack-disable_css_animations.insert_middleware" do |app|
          app.middleware.insert_before ActionDispatch::ContentSecurityPolicy::Middleware, DisableCSSAnimations
        rescue RuntimeError
          app.middleware.use DisableCSSAnimations
        end
      end
    end

    def initialize app
      @app = app
    end

    def call env
      @status, @headers, @body = @app.call(env)
      return [@status, @headers, @body] unless html?

      @style_nonce = directive_nonces["style-src"]

      response = Rack::Response.new([], @status, @headers)
      @body.each do |fragment|
        response.write inject(fragment)
      end
      @body.close if @body.respond_to?(:close)

      response.finish
    end

    private

    def html?
      @headers["Content-Type"] =~ /html/
    end

    def csp_header
      @headers["Content-Security-Policy"] ||
        @headers["content-security-policy"] ||
        @headers["Content-Security-Policy-Report-Only"] ||
        @headers["content-security-policy-report-only"] ||
        ""
    end

    def directive_nonces
      csp_header.split(";").each_with_object({}) do |directive, nonces|
        tokens = directive.split
        name = tokens.shift
        next unless name
        nonce = tokens.find { |t| t =~ /\A'nonce-(.+)'\z/ } && $1
        nonces[name] = nonce if nonce
      end
    end

    def style_tag
      @style_nonce ? %(<style nonce="#{@style_nonce}">) : "<style>"
    end

    def inject response
      markup = <<-CSS
        #{style_tag}
          * {
            animation-delay: 0s !important;
            animation-duration: 0.01s !important;
            transition-delay: 0s !important;
            transition-duration: 0.01s !important;
            scroll-behavior: auto !important;
          }
        </style>
      CSS
      response.gsub(%r{</head>}, "#{markup}</head>")
    end
  end
end
