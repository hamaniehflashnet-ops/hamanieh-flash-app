import os
import re
import sys
import shutil

manifest_path = "android/app/src/main/AndroidManifest.xml"

with open(manifest_path, "r", encoding="utf-8") as f:
    content = f.read()

permissions = (
    '    <uses-permission android:name="android.permission.INTERNET" />\n'
    # Requise a partir d'Android 13 (API 33) pour afficher des notifications.
    '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n'
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

network_config = """<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">ecmanager5.pro-fhi.net</domain>
    </domain-config>
    <base-config cleartextTrafficPermitted="false" />
</network-security-config>
"""
with open(os.path.join(xml_dir, "network_security_config.xml"), "w", encoding="utf-8") as f:
    f.write(network_config)

print("AndroidManifest.xml patched:")
print(content)

if "android.permission.INTERNET" in content and "networkSecurityConfig" in content:
    print("OK: permission INTERNET et configuration reseau presentes.")
else:
    print("ERREUR: la configuration du manifeste a echoue.")
    sys.exit(1)

# ---- Firebase Cloud Messaging (notifications push) ----
# google-services.json doit etre depose a la racine du depot (a cote de
# pubspec.yaml) : il est copie ici au bon endroit pour que le plugin
# Google Services le trouve pendant le build.
root_google_services = "google-services.json"
app_google_services = "android/app/google-services.json"

if os.path.exists(root_google_services):
    shutil.copyfile(root_google_services, app_google_services)
    print("google-services.json copie dans android/app/.")

    project_gradle = "android/build.gradle.kts"
    if os.path.exists(project_gradle):
        with open(project_gradle, "r", encoding="utf-8") as f:
            g = f.read()
        if "com.google.gms.google-services" not in g:
            g = g.replace(
                "plugins {",
                'plugins {\n    id("com.google.gms.google-services") version "4.4.2" apply false',
                1,
            )
            with open(project_gradle, "w", encoding="utf-8") as f:
                f.write(g)

    app_gradle = "android/app/build.gradle.kts"
    if os.path.exists(app_gradle):
        with open(app_gradle, "r", encoding="utf-8") as f:
            a = f.read()
        if "com.google.gms.google-services" not in a:
            a = a.replace(
                'id("kotlin-android")',
                'id("kotlin-android")\n    id("com.google.gms.google-services")',
                1,
            )
            with open(app_gradle, "w", encoding="utf-8") as f:
                f.write(a)
    print("Plugin Google Services applique dans les fichiers Gradle.")
else:
    print(
        "AVERTISSEMENT: google-services.json absent a la racine du depot -- "
        "l'appli sera construite SANS notifications push."
    )
