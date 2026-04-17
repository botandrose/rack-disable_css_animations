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
    refute_includes last_response.body, "nonce="
  end

  def test_injects_before_closing_head
    get "/"

    style_index = last_response.body.index("<style")
    head_close_index = last_response.body.index("</head>")
    assert style_index < head_close_index
  end

  def test_style_src_nonce_is_copied_onto_style_tag
    self.response_headers["Content-Security-Policy"] = "style-src 'nonce-abc123' 'self'; script-src 'nonce-xyz789'"

    get "/"

    assert_includes last_response.body, %(<style nonce="abc123">)
    refute_includes last_response.body, "<style>"
  end

  def test_csp_without_style_src_nonce_injects_plain_style_tag
    self.response_headers["Content-Security-Policy"] = "default-src 'self'; script-src 'nonce-xyz789'"

    get "/"

    assert_includes last_response.body, "<style>"
    refute_includes last_response.body, "nonce="
  end

  def test_csp_with_style_src_but_no_nonce_injects_plain_style_tag
    self.response_headers["Content-Security-Policy"] = "style-src 'self' 'unsafe-inline'"

    get "/"

    assert_includes last_response.body, "<style>"
    refute_includes last_response.body, "nonce="
  end

  def test_lowercase_csp_header_is_also_recognized
    self.response_headers = { "Content-Type" => "text/html", "content-security-policy" => "style-src 'nonce-lower1'" }

    get "/"

    assert_includes last_response.body, %(<style nonce="lower1">)
  end

  def test_report_only_csp_header_nonce_is_used_when_enforcing_header_absent
    self.response_headers["Content-Security-Policy-Report-Only"] = "style-src 'nonce-reportonly1'"

    get "/"

    assert_includes last_response.body, %(<style nonce="reportonly1">)
  end

  def test_lowercase_report_only_csp_header_is_also_recognized
    self.response_headers = { "Content-Type" => "text/html", "content-security-policy-report-only" => "style-src 'nonce-reportonly2'" }

    get "/"

    assert_includes last_response.body, %(<style nonce="reportonly2">)
  end

  def test_enforcing_header_takes_precedence_over_report_only
    self.response_headers["Content-Security-Policy"] = "style-src 'nonce-enforced'"
    self.response_headers["Content-Security-Policy-Report-Only"] = "style-src 'nonce-reportonly'"

    get "/"

    assert_includes last_response.body, %(<style nonce="enforced">)
    refute_includes last_response.body, "reportonly"
  end
end
