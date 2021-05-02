import os
from io import BytesIO
import requests
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

# https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json

TOKEN = os.getenv("GARMIN_ACCESS_TOKEN")
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
    device = next(
        device for device in devices if device["name"] == product.attrib["id"]
    )
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