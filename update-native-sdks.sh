#!/bin/bash

version=$(curl -s https://raw.githubusercontent.com/jitsi/jitsi-meet-release-notes/master/CHANGELOG-MOBILE-SDKS.md | grep -E '# \[[0-9]+\.[0-9]+\.[0-9]+\]' | head -1 | cut -d']' -f1 | cut -d'[' -f2)
gradle_repo="org.jitsi.react:jitsi-meet-sdk"
pod_repo="JitsiMeetSDK"
version_regex="(\d+\.)?(\d+\.)?(\*|\d+)"
perl -i -pe"s/$gradle_repo:$version_regex/$gradle_repo:$version/" android/build.gradle
perl -i -pe"s/($pod_repo', )'$version_regex'/\1'$version'/" ios/jitsi_meet_flutter_sdk.podspec

cd example/ios

pod --silent update JitsiMeetSDK

cd ../..

git checkout main
git pull origin main --rebase
git add android/build.gradle example/ios/Podfile.lock ios/jitsi_meet_flutter_sdk.podspec
git commit -m "chore(deps): update native sdks to $version"
git push origin main
