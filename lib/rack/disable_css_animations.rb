require "rack/disable_css_animations/version"

module Rack
  class DisableCSSAnimations
    def initialize app
      @app = app
    end

    def call env
      @status, @headers, @body = @app.call(env)
      return [@status, @headers, @body] unless html?

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

    def inject response
      markup = <<-CSS
        <style>
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
