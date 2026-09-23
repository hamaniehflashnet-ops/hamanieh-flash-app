import os
import re
import sys

manifest_path = "android/app/src/main/AndroidManifest.xml"

with open(manifest_path, "r", encoding="utf-8") as f:
    content = f.read()

permissions = (
    '    <uses-permission android:name="android.permission.INTERNET" />\n'
)
content = re.sub(r"(<manifest[^>]*>\n)", r"\1" + permissions, content, count=1)

content = content.replace(
    'android:label="hamanieh_flash"',
    'android:label="hamanieh_flash"\n'
    '        android:allowBackup="false"\n'
    '        android:usesCleartextTraffic="false"\n'
    '        android:networkSecurityConfig="@xml/network_security_config"',
    1,
)

with open(manifest_path, "w", encoding="utf-8") as f:
    f.write(content)

# Autorise une connexion non securisee (http) uniquement vers le serveur
# de streaming radio, sans affaiblir la securite du reste de l'application.
xml_dir = "android/app/src/main/res/xml"
os.makedirs(xml_dir, exist_ok=True)
with open(os.path.join(xml_dir, "network_security_config.xml"), "w", encoding="utf-8") as f:
    f.write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<network-security-config>\n"
        '    <domain-config cleartextTrafficPermitted="true">\n'
        '        <domain includeSubdomains="true">ecmanager5.pro-fhi.net</domain>\n'
        "    </domain-config>\n"
        '    <base-config cleartextTrafficPermitted="false" />\n'
        "</network-security-config>\n"
    )

print("----- AndroidManifest.xml -----")
print(content)
print("---------
