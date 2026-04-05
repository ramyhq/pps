#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Starting deployment process...${NC}"
flutter --version

# 1. Clean the project
echo -e "${YELLOW}🧹 Cleaning project...${NC}"
flutter clean
flutter pub get

# 2. Update build info with current date (Cairo Time)
echo -e "${YELLOW}📅 Updating build date...${NC}"
DATE_STR=$(TZ='Africa/Cairo' date '+%Y-%m-%d %H:%M:%S')
mkdir -p lib/core/utils
echo "const String deployDate = \"$DATE_STR\";" > lib/core/utils/build_info.dart
echo -e "${GREEN}✅ Build date updated to: $DATE_STR${NC}"

# 3. Run flutter build
echo -e "${YELLOW}🔨 Building Flutter web (Release Mode)...${NC}"
#### flutter build web --release --no-tree-shake-icons --pwa-strategy=none
flutter build web --release --pwa-strategy=none


# Check if build was successful (redundant with set -e, but good for clarity)
if [ $? -eq 0 ]; then
    # Purpose: Disable PWA/SW in generated web output to force fresh loads. Context: Firebase Hosting deploy pipeline. Timestamp: 2026-02-16 10:40
perl -0777 -i -pe 's/serviceWorkerSettings:\s*\{[^}]*\}/serviceWorkerSettings: null/g' build/web/flutter_bootstrap.js
###### new
    ENGINE_REVISION=$(python3 - <<'PY'
import re
from pathlib import Path
text = Path("build/web/flutter_bootstrap.js").read_text(encoding="utf-8", errors="ignore")
m = re.search(r'"engineRevision":"([^"]+)"', text)
print(m.group(1) if m else "")
PY
)

    if [ -n "$ENGINE_REVISION" ] && [ -d "build/web/canvaskit" ]; then
        mkdir -p "build/web/canvaskit/$ENGINE_REVISION"
        find "build/web/canvaskit" -mindepth 1 -maxdepth 1 ! -name "$ENGINE_REVISION" -exec mv {} "build/web/canvaskit/$ENGINE_REVISION/" \;
        perl -0777 -i -pe "s/serviceWorkerSettings:\\s*null/serviceWorkerSettings: null, config: {canvasKitBaseUrl: \\\"canvaskit\\/$ENGINE_REVISION\\/\\\"}/g" build/web/flutter_bootstrap.js
    fi
######new end
rm -f build/web/manifest.json
perl -0777 -i -pe 's/\s*<link rel="manifest" href="manifest\.json">\s*//g' build/web/index.html

rm -f build/web/flutter_service_worker.js
grep -n "serviceWorkerSettings" build/web/flutter_bootstrap.js | head


    echo -e "${GREEN}🎉 Build successful! Ready for deployment.${NC}"
    # firebase deploy --only hosting
    if ! command -v firebase >/dev/null 2>&1; then
        echo -e "${RED}❌ Firebase CLI is not installed. Install firebase-tools before running deploy.${NC}"
        exit 1
    fi
    firebase deploy --only functions
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi
 