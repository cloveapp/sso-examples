from flask import Flask, redirect, request
import os
import jwt

app = Flask(__name__)


@app.route("/sso/clove")
def sso_clove():
    # If the user is not logged in, store the fact that the request came from Clove
    # via a specific hub_domain (in cookie for example). After they are logged in,
    # redirect them to the generated URL.

    jwt_s = jwt.encode(generate_user_payload(), secret(), algorithm="HS256")
    domain = request.args.get('hub_domain')
    verify_domain(domain)

    return redirect(f"https://{domain}/sso/jwt?jwt={jwt_s}")


def verify_domain(domain):
    valid = domain == "preview.cloveapp.io" or domain.endswith(".mycompany.com")

    if not valid:
        raise Exception("Invalid hub_domain")


def generate_user_payload():
    return {
        "user": {
            "id": 1000,
            "given_name": "Adam",
            "family_name": "Admin",
            "name": "Adam Admin",
            "email": "sso+admin@cloveapp.io",
            "custom_data": {
                "sfdc_contact_id": "0034W00002IZh2YQAT"
            },
            "organization": {
                "id": 2000,
                "name": "SSO Demo Org",
                "custom_data": {
                    "sfdc_account_id": "0014W00002Cu9AiQAJ"
                }
            }
        }
    }


def secret():
    return os.getenv('SSO_SECRET')


if secret() == None:
    raise Exception("SSO_SECRET is not set")
