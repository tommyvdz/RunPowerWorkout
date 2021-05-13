import os
import requests
import xml.etree.ElementTree as ET
from pathlib import Path
from bs4 import BeautifulSoup

GARMIN_USERNAME = os.getenv("GARMIN_USERNAME")
GARMIN_PASSWORD = os.getenv("GARMIN_PASSWORD")
APP_ID = os.getenv("APP_ID")
STORE_ID = os.getenv("STORE_ID")
DEV_ID = os.getenv("DEV_ID")
TAG_NAME = os.getenv("TAG_NAME")
BETA_APP = os.getenv("BETA_APP")

url = "https://sso.garmin.com/sso/signin"

s = requests.Session()

querystring = {
    "service": f"https://apps.garmin.com/en-US/apps/{STORE_ID}",
    "webhost": "apps.garmin.com",
    "source": "https://apps.garmin.com/login",
    "redirectAfterAccountLoginUrl": f"https://apps.garmin.com/en-US/apps/{STORE_ID}",
    "redirectAfterAccountCreationUrl": f"https://apps.garmin.com/en-US/apps/{STORE_ID}",
    "gauthHost": "https://sso.garmin.com/sso",
    "locale": "en_US",
    "id": "gauth-widget",
    "cssUrl": "//static.garmin.com/com.garmin.connect/ui/css/gauth-custom-v1.2-min.css",
    "privacyStatementUrl": "//www.garmin.com/en-US/privacy/connect/",
    "clientId": "APPS_LIBRARY",
    "rememberMeShown": "true",
    "rememberMeChecked": "false",
    "createAccountShown": "true",
    "openCreateAccount": "false",
    "displayNameShown": "false",
    "consumeServiceTicket": "true",
    "initialFocus": "true",
    "embedWidget": "false",
    "generateExtraServiceTicket": "true",
    "generateTwoExtraServiceTickets": "false",
    "generateNoServiceTicket": "false",
    "globalOptInShown": "false",
    "globalOptInChecked": "false",
    "mobile": "false",
    "connectLegalTerms": "false",
    "showTermsOfUse": "false",
    "showPrivacyPolicy": "false",
    "showConnectLegalAge": "false",
    "locationPromptShown": "true",
    "showPassword": "true",
    "useCustomHeader": "false",
    "mfaRequired": "false",
    "performMFACheck": "false",
    "rememberMyBrowserShown": "false",
    "rememberMyBrowserChecked": "false",
}

payload = ""
response = s.get(url, data=payload, params=querystring)

soup = BeautifulSoup(response.content, "html.parser")

token = soup.find_all("input", {"name": "_csrf"})[0].get("value")

# print(token)

# print(s.cookies.get_dict())

payload = {
    "username": GARMIN_USERNAME,
    "password": GARMIN_PASSWORD,
    "embed": "false",
    "_csrf": token,
    "rememberme": "on",
}

headers = {
    "Accept-Language": "en",
    "Sec-Fetch-Dest": "iframe",
    "Content-Type": "application/x-www-form-urlencoded",
    "Cache-Control": "max-age=0",
    "Origin": "https://sso.garmin.com",
    "Host": "sso.garmin.com",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Sec-Fetch-Site": "same-origin",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
}

response = s.post(url, data=payload, headers=headers, params=querystring)
print(response.status_code)

url = f"https://apps.garmin.com/en-US/developer/{DEV_ID}/apps/{STORE_ID}/update"

s.get(url, headers=headers, params=querystring)

headers = {
    "Accept-Language": "en",
    "Sec-Fetch-Dest": "document",
    "Cache-Control": "max-age=0",
    "Origin": "https://sso.garmin.com",
    "Host": "sso.garmin.com",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Sec-Fetch-Site": "same-origin",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
}

response = s.post(
    url,
    headers=headers,
    files={
        "file": (
            f"RunPowerWorkout-{TAG_NAME}.iq",
            open(f"/tmp/RunPowerWorkout-{TAG_NAME}.iq", "rb"),
            "application/octet-stream",
        ),
        "appVersion": (None, TAG_NAME),
        "betaApp": (None, BETA_APP),
    },
)
print(response.status_code)
print(response.content)