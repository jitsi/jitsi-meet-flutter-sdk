#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Please specify a version"
    exit 1
fi

version=$1
echo -e "## $version \n" > temp
git fetch
git checkout main
git pull origin main --rebase

latest_relase=$(git describe --tags --abbrev=0)
git log $latest_relase..HEAD --no-merges --oneline --pretty=format:'* %s [%h](https://github.com/jitsi/jitsi-meet-flutter-sdk/commit/%H).' >> temp

echo -e "\n" >> temp;

cat CHANGELOG.md >> temp;

cat temp > CHANGELOG.md;

rm temp;
badge_url="https:\/\/img.shields.io\/badge\/pub-v";
badge_color="blue";
version_regex="(\d+\.)?(\d+\.)?(\*|\d+)"
perl -i -pe"s/$badge_url$version_regex-$badge_color/$badge_url$version-$badge_color/" README.md

package_name="jitsi_meet_flutter_sdk"
perl -i -pe"s/$package_name: \^$version_regex/$package_name: \^$version/" README.md

perl -i -pe"s/version: $version_regex/version: $version/" pubspec.yaml

cd example
flutter pub get
cd ..

git add CHANGELOG.md pubspec.yaml README.md example/pubspec.lock
git commit -m "v$version"
git push origin main