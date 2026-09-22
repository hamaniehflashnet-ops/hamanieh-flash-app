import re
import sys

path = "android/app/src/main/AndroidManifest.xml"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

permissions = (
    '    <uses-permission android:name="android.permission.INTERNET" />\n'
)
content = re.sub(r"(<manifest[^>]*>\n)", r"\1" + permissions, content, count=1)

content = content.replace(
    'android:label="hamanieh_flash"',
    'android:label="hamanieh_flash"\n        android:allowBackup="false"\n        android:usesCleartextTraffic="false"',
    1,
)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("----- AndroidManifest.xml -----")
print(content)
print("--------------------------------")

if "android.permission.INTERNET" in content:
    print("Permission INTERNET bien presente dans le manifeste.")
else:
    print("ERREUR : la configuration du manifeste a echoue !")
    sys.exit(1)
