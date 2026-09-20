import re
import sys

path = "android/app/src/main/AndroidManifest.xml"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

permissions = (
    '    <uses-permission android:name="android.permission.INTERNET" />\n'
    '    <uses-permission android:name="android.permission.WAKE_LOCK" />\n'
    '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />\n'
    '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />\n'
    '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n'
)
content = re.sub(r"(<manifest[^>]*>\n)", r"\1" + permissions, content, count=1)

content = content.replace(
    'android:label="hamanieh_flash"',
    'android:label="hamanieh_flash"\n        android:allowBackup="false"\n        android:usesCleartextTraffic="false"',
    1,
)

service_block = (
    '        <service android:name="com.ryanheise.audioservice.AudioService"\n'
    '            android:foregroundServiceType="mediaPlayback"\n'
    '            android:exported="true">\n'
    '            <intent-filter>\n'
    '                <action android:name="android.media.browse.MediaBrowserService" />\n'
    '            </intent-filter>\n'
    '        </service>\n'
    '        <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"\n'
    '            android:exported="true">\n'
    '            <intent-filter>\n'
    '                <action android:name="android.intent.action.MEDIA_BUTTON" />\n'
    '            </intent-filter>\n'
    '        </receiver>\n'
)
content = content.replace("</application>", service_block + "    </application>", 1)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("----- AndroidManifest.xml -----")
print(content)
print("--------------------------------")

if "android.permission.INTERNET" in content and "AudioService" in content:
    print("Permission INTERNET et service audio bien presents dans le manifeste.")
else:
    print("ERREUR : la configuration du manifeste a echoue !")
    sys.exit(1)
