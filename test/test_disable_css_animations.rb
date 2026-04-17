require "minitest/autorun"
require "rack/test"
require "rack/disable_css_animations"

class TestDisableCSSAnimations < Minitest::Test
  include Rack::Test::Methods

  HTML_BODY = "<html><head><title>Test</title></head><body>hi</body></html>"

  attr_accessor :response_status, :response_headers, :response_body

  def app
    outer_self = self
    Rack::DisableCSSAnimations.new(lambda do |_env|
      [outer_self.response_status, outer_self.response_headers, [outer_self.response_body]]
    end)
  end

  def setup
    self.response_status = 200
    self.response_headers = { "Content-Type" => "text/html" }
    self.response_body = HTML_BODY
  end

  def test_non_html_response_is_passed_through_unchanged
    self.response_headers = { "Content-Type" => "application/json" }
    self.response_body = %({"foo":"bar"})

    get "/"

    assert_equal %({"foo":"bar"}), last_response.body
  end

  def test_html_response_injects_style_tag
    get "/"

    assert_includes last_response.body, "<style>"
    assert_includes last_response.body, "animation-duration: 0.01s !important"
  end

  def test_injects_before_closing_head
    get "/"

    style_index = last_response.body.index("<style>")
    head_close_index = last_response.body.index("</head>")
    assert style_index < head_close_index
  end
end
