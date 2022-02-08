import os
import requests
import xml.etree.ElementTree as ET
from pathlib import Path
from bs4 import BeautifulSoup
from requests_toolbelt import MultipartEncoder
import cloudscraper
import random, string
import time

GARMIN_USERNAME = os.getenv("GARMIN_USERNAME")
GARMIN_PASSWORD = os.getenv("GARMIN_PASSWORD")
APP_ID = os.getenv("APP_ID")
STORE_ID = os.getenv("STORE_ID")
DEV_ID = os.getenv("DEV_ID")
TAG_NAME = os.getenv("TAG_NAME")
BETA_APP = os.getenv("BETA_APP")
DEV_EMAIL = os.getenv("DEV_EMAIL")

if GARMIN_USERNAME is None or GARMIN_PASSWORD is None:
    print("Issue getting Garmin credentials")
    exit(1)

try:
    release_notes = requests.get(
        f"https://api.github.com/repos/{'samueldumont' if BETA_APP == 'true' else 'tommyvdz'}/RunPowerWorkout/releases/tags/{TAG_NAME}"
    ).json()["body"]
except:
    release_notes = ""

print(f"Uploading {STORE_ID} with tag {TAG_NAME}. Beta : {BETA_APP}.")

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
    "service": "https://apps.garmin.com/en-US",
    "webhost": "apps.garmin.com",
    "source": "https://apps.garmin.com/login",
    "redirectAfterAccountLoginUrl": "https://apps.garmin.com/en-US",
    "redirectAfterAccountCreationUrl": "https://apps.garmin.com/en-US",
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
    "embed": "false",
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
print(f"Login result: {response.status_code}")

if response.status_code != 200:
    print(f"{len(GARMIN_USERNAME)} {len(GARMIN_PASSWORD)}")
    print(f"{response.text}")
    exit(1)

### UPLOAD FILE

url = f"https://apps.garmin.com/en-US/developer/{DEV_ID}/apps/{STORE_ID}/update"

headers = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
}

scraper.get(url, headers=headers)

m = MultipartEncoder(
    fields={
        "appVersion": TAG_NAME,
        "betaApp": BETA_APP,
        "submit": "",
        "file": (
            f"RunPowerWorkout-{TAG_NAME}.iq",
            open(f"/tmp/RunPowerWorkout-{TAG_NAME}.iq", "rb"),
            "application/octet-stream",
        ),
    },
    boundary="----WebKitFormBoundary" + "".join(random.sample(string.ascii_letters + string.digits, 16)),
)

headers = {
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Cache-Control": "no-cache",
    "Content-Type": m.content_type,
    "Origin": "https://apps.garmin.com",
    "Referer": url,
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Site": "same-origin",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
}

response = scraper.post(url, headers=headers, data=m, allow_redirects=True)
print(f"Upload result : {response.status_code}")

# UPDATE DETAILS, STILL TODO
url = f"https://apps.garmin.com/en-US/developer/{DEV_ID}/apps/{STORE_ID}/edit"
response = scraper.get(url)

soup = BeautifulSoup(response.text, "html.parser")

appDescription = soup.find("textarea", {"id": "app-desc-en"}).renderContents()

m = MultipartEncoder(
    fields=[
        ("localizedAppModel[0].appLocale", "en"),
        (
            "localizedAppModel[0].appTitle",
            "RunPowerWorkout - beta" if BETA_APP == "true" else "RunPowerWorkout",
        ),
        ("localizedAppModel[0].appDescription", appDescription),
        ("localizedAppModel[0].appWhatsNew", release_notes),
        (
            "localizedAppModel[0].heroImageObject",
            (
                "",
                "",
                "application/octet-stream",
            ),
        ),
        ("localizedAppModel[0].deleteHeroImage", "false"),
        ("localizedAppModel[0].heroImageUrl", ""),
        ("category", "251"),
        ("policy", "no"),
        ("policyUrl", ""),
        ("antPlusProfiles", "no"),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("_antPlusProfilesModel.selectedAntPlusProfiles", (None, "on")),
        ("antPlusProfilesModel.enteredAntPlusProfileComments[9999999]", ""),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("_countriesModel.selectedCountries", "on"),
        ("regionalLimits", "no"),
        (
            "iconFile",
            (
                "",
                "",
                "application/octet-stream",
            ),
        ),
        (
            "screenshotFiles[0]",
            (
                "",
                "",
                "application/octet-stream",
            ),
        ),
        ("screenshotIds[0]", ""),
        ("deleted[0]", "false"),
        (
            "screenshotFiles[1]",
            (
                "",
                "",
                "application/octet-stream",
            ),
        ),
        ("screenshotIds[1]", ""),
        ("deleted[1]", "false"),
        (
            "screenshotFiles[2]",
            (
                "",
                "",
                "application/octet-stream",
            ),
        ),
        ("screenshotIds[2]", ""),
        ("deleted[2]", "false"),
        (
            "screenshotFiles[3]",
            (
                "",
                "",
                "application/octet-stream",
            ),
        ),
        ("screenshotIds[3]", ""),
        ("deleted[3]", "false"),
        (
            "screenshotFiles[4]",
            (
                "",
                "",
                "application/octet-stream",
            ),
        ),
        ("screenshotIds[4]", ""),
        ("deleted[4]", "false"),
        ("videoUrl", ""),
        ("devEmail", DEV_EMAIL),
        ("sourceUrl", "https://github.com/tommyvdz/RunPowerWorkout"),
        ("reviewNotificationActive", "true"),
        ("migrationAllowed", "true"),
        ("paymentModelCheck", "no"),
        ("iosAppUrl", ""),
        ("androidAppUrl", ""),
        ("hardwareProductUrl", ""),
        ("betaApp", BETA_APP),
        ("submit", ""),
    ],
    boundary="----WebKitFormBoundary" + "".join(random.sample(string.ascii_letters + string.digits, 16)),
)

headers = {
    "Accept-Encoding": "gzip, deflate, br",
    "Accept-Language": "en",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    "Cache-Control": "no-cache",
    "Content-Type": m.content_type,
    "Origin": "https://apps.garmin.com",
    "Referer": url,
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Site": "same-origin",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36",
}

response = scraper.post(url, headers=headers, data=m, allow_redirects=True)
print(f"What's new update result : {response.status_code}")
