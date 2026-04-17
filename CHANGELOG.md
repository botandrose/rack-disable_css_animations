# Changelog

## 0.5.1

- Recognize the `Content-Security-Policy-Report-Only` header (in both canonical and lowercase form) when no enforcing `Content-Security-Policy` header is present, so the injected `<style>` tag's nonce matches in apps running CSP in report-only mode.
- Insert the middleware before `ActionDispatch::ContentSecurityPolicy::Middleware` so the CSP header has already been added to the response by the time we read it. Previously the middleware ran before CSP on the response, so the header was always absent.

## 0.5.0

- Add CSP nonce support: when the response's `Content-Security-Policy` header sets a `style-src 'nonce-…'`, the injected `<style>` tag now carries a matching `nonce` attribute so it is not blocked by CSP.

## 0.4.0

- Add stub for manual requiring.
- Automatically add to the middleware stack when required after Rails.

## 0.3.0

- Disable `scroll-behavior` as well.
- CSS prefixes are no longer needed.

## 0.2.0

- Actually disable the animations.
- `0` is not a valid value for the `animation-duration` property.

## 0.1.1

- Use prefix methods too (PhantomJS needed the `-webkit` prefix).

## 0.1.0

- Initial release.
