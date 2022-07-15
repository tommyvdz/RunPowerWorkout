import os
import requests
import xml.etree.ElementTree as ET
from pathlib import Path
from bs4 import BeautifulSoup
from requests_toolbelt import MultipartEncoder
import cloudscraper
import random, string
import time
import re
from io import BytesIO
import zipfile


GARMIN_USERNAME = os.getenv("GARMIN_USERNAME")
GARMIN_PASSWORD = os.getenv("GARMIN_PASSWORD")

if GARMIN_USERNAME is None or GARMIN_PASSWORD is None:
    print("Issue getting Garmin credentials")
    exit(1)

scraper = cloudscraper.create_scraper()  # returns a CloudScraper instance

### GET INITIAL COOKIES

headers = {
    "Connection": "keep-alive",
    "Pragma": "no-cache",
    "Cache-Control": "no-cache",
    "sec-ch-ua-mobile": "?0",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-User": "?1",
    "Sec-Fetch-Dest": "document",
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en",
}

querystring = {
    "service": "https://sso.garmin.com/sso/embed",
    "source": "https://sso.garmin.com/sso/embed",
    "redirectAfterAccountLoginUrl": "https://sso.garmin.com/sso/embed",
    "redirectAfterAccountCreationUrl": "https://sso.garmin.com/sso/embed",
    "gauthHost": "https://sso.garmin.com/sso",
    "locale": "en",
    "id": "gauth-widget",
    "cssUrl": "https://developer.garmin.com/downloads/connect-iq/sdk-manager-login.css",
    "clientId": "ConnectIqSdkManager",
    "rememberMeShown": "false",
    "rememberMeChecked": "false",
    "createAccountShown": "true",
    "openCreateAccount": "false",
    "displayNameShown": "false",
    "consumeServiceTicket": "true",
    "initialFocus": "true",
    "embedWidget": "true",
    "generateExtraServiceTicket": "false",
    "generateTwoExtraServiceTickets": "false",
    "generateNoServiceTicket": "false",
    "globalOptInShown": "false",
    "globalOptInChecked": "false",
    "mobile": "false",
    "connectLegalTerms": "false",
    "showTermsOfUse": "false",
    "showPrivacyPolicy": "false",
    "showConnectLegalAge": "false",
    "locationPromptShown": "false",
    "showPassword": "true",
    "useCustomHeader": "false",
    "mfaRequired": "false",
    "performMFACheck": "false",
    "rememberMyBrowserShown": "false",
    "rememberMyBrowserChecked": "false",
}

url = f"https://apps.garmin.com/en-US/"

scraper.get(url, headers=headers)

#### LOGIN

url = "https://sso.garmin.com/sso/signin"

payload = ""

headers = {
    "Accept-Language": "en",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Referer": "https://apps.garmin.com/",
    "Sec-Fetch-Dest": "iframe",
    "Sec-Fetch-Site": "same-origin",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
}
response = scraper.get(url, headers=headers, params=querystring)
soup = BeautifulSoup(response.content, "html.parser")

token = soup.find_all("input", {"name": "_csrf"})[0].get("value")
query = soup.find_all("input", {"id": "queryString"})[0].get("value")

payload = {
    "username": GARMIN_USERNAME,
    "password": GARMIN_PASSWORD,
    "embed": "true",
    "_csrf": token,
    "rememberme": "on",
}

headers = {
    "Accept-Language": "en",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Cache-Control": "no-cache",
    "Content-Type": "application/x-www-form-urlencoded",
    "Origin": "https://sso.garmin.com",
    "DNT": "1",
    "Referer": f"{url}?{query}",
    "Sec-Fetch-Dest": "iframe",
    "Sec-Fetch-Site": "same-origin",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
}

response = scraper.post(url, data=payload, headers=headers, params=querystring)
soup = BeautifulSoup(response.text, "html.parser")
pattern = re.compile(r"var response_url\s+=\s+\"(.*?)ticket=(.*?)\";", re.MULTILINE | re.DOTALL)
service_ticket = None
for script in soup.find_all("script", {"src": False}):
    if script:
        m = pattern.search(script.string)
        if m:
            service_ticket = m.group(2)

if not service_ticket:
    print(f"Cannot find the ticket")
    exit(1)

print(f"Login result: {response.status_code}")

if response.status_code != 200:
    print(f"{len(GARMIN_USERNAME)} {len(GARMIN_PASSWORD)}")
    print(f"{response.text}")
    exit(1)

url = "https://services.garmin.com/api/oauth/token"

payload = f"grant_type=service_ticket&client_id=CIQ_SDK_MANAGER&service_ticket={service_ticket}&service_url=https%3A%2F%2Fsso.garmin.com%2Fsso%2Fembed"
headers = {
    "Host": "services.garmin.com",
    "Accept": "*/*",
    "Accept-Charset": "UTF-8",
    "Content-Length": "148",
    "Content-Type": "application/x-www-form-urlencoded",
}

token = requests.request("POST", url, data=payload, headers=headers).json()

TOKEN = token["access_token"]
CIQ_PATH = f"{str(Path.home())}/.Garmin/ConnectIQ"

os.makedirs(f"{CIQ_PATH}/Fonts", exist_ok=True)
os.makedirs(f"{CIQ_PATH}/Devices", exist_ok=True)

devices = requests.get(
    url="https://api.gcs.garmin.com/ciq-product-onboarding/devices",
    headers={"Authorization": f"Bearer {TOKEN}"},
).json()

fonts = requests.get(
    url="https://api.gcs.garmin.com/ciq-product-onboarding/fonts",
    headers={"Authorization": f"Bearer {TOKEN}"},
).json()

manifest = ET.parse("manifest.xml").getroot()

for product in manifest.findall(".//{http://www.garmin.com/xml/connectiq}product"):
    device = next(device for device in devices if device["name"] == product.attrib["id"])
    if not os.path.exists(f"{CIQ_PATH}/Devices/{device['name']}"):
        print(f"Need to download {device['name']} !")
        request = requests.get(
            url=f"https://api.gcs.garmin.com/ciq-product-onboarding/devices/{device['partNumber']}/ciqInfo",
            headers={"Authorization": f"Bearer {TOKEN}"},
        )

        file = zipfile.ZipFile(BytesIO(request.content))
        file.extractall(f"{CIQ_PATH}/Devices/{device['name']}")

for font in fonts:
    if not os.path.isfile(f"{CIQ_PATH}/Fonts/{font['name']}.cft"):
        print(f"Need to download {font['name']} !")
        request = requests.get(
            url=f"https://api.gcs.garmin.com/ciq-product-onboarding/fonts/font?fontName={font['name']}",
            headers={"Authorization": f"Bearer {TOKEN}"},
        )

        file = zipfile.ZipFile(BytesIO(request.content))
        file.extractall(f"{CIQ_PATH}/Fonts")
