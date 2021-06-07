# Clove SSO Example (Python)

This is an example app demonstrating how to integrate with [Clove's SSO](https://hub.cloveapp.io/hc/a/product-single-sign-on).

# Setup

1. Install a recent python version (3.9.2 for this demo)
2. Setup a virtualenv
  * `python3 -m venv venv`
  * `. venv/bin/activate`
3. Install dependencies
  * `python -m pip install -r requirements.txt`
4. Setup an SSO provider with the URL `http://localhost:5000/sso/clove`
5. Receive a shared secret (SSO setup page) to be used below

# Run

* export SSO_SECRET=SHARED_SECRET_FROM_CLOVE
* `flask run`

# Notes

The `verify_domain/1` function should be adjusted with your production instance URL. We recommend
verifying the `hub_domain` parameter to prevent redirection vulnerabilities. Always include
`preview.cloveapp.io` to enable Clove's preview feature.
