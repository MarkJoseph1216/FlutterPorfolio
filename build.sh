#!/bin/bash
set -e

git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get
flutter/bin/flutter build web --release --pwa-strategy=none --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY