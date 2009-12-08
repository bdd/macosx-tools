#!/usr/bin/env sh

# Let's be defensive. This tool may have sharp corners.
set -o nounset
set -o errexit
set -x

REMOTE='http://build.chromium.org/buildbot/snapshots/chromium-rel-mac'

if ! command -v curl >/dev/null; then
	echo "I couldn't find 'curl' in the PATH."
	exit 1
fi

ask_yesno () {
	local _R

	echo -n $1 "[yes/no]: " && read _R

	if echo ${_R} | grep -Ei '^y(es)?$' >/dev/null; then
		return 0
	elif echo ${_R} | grep -Ei '^n(o)?$' >/dev/null; then
		return 1
	else
		return 255
	fi
}

chromium_version () {
	local _crinfo
	_crinfo='/Applications/Chromium.app/Contents/Info.plist'
	if [ -f ${_crinfo} ]; then
		grep -A 1 SVNRevision ${_crinfo} | tail -1 | grep -Eo '[0-9]+'
	else
		echo 0
	fi
}

remote_latest () {
	local _url _revision
	_url=${REMOTE}"/LATEST"
	_revision=`curl --silent --fail --connect-timeout 5 --max-time 10 ${_url}`

	# Ensure curl didn't fail (aka HTTP/200)
	if [ $? -eq 0 ]; then
		echo ${_revision}
	fi
}

our_version=`chromium_version`
latest_version=`remote_latest`

if [ -z $latest_version ]; then
	echo "Couldn't reach remote to get latest version info."
	exit 1
fi

if [ $latest_version -eq $our_version ]; then
	echo "We are up to date with version ${latest_version}."
	exit 0
fi

target_url="${REMOTE}/${latest_version}/chrome-mac.zip"
output_file="${HOME}/Downloads/Chromium-${latest_version}.zip"

echo "We have $our_version and latest is $latest_version."
echo "Downloading..."
curl --fail --connect-timeout 5 ${target_url} -o ${output_file}

if [ $? -ne 0 ]; then
	echo "Download failed. Try again later."
	exit 1
fi;

# Chromium running?
if killall -0 Chromium  2>/dev/null; then
	if ask_yesno "Chromium is running. Should I kill it before upgrade?"; then
		killall Chromium
		sleep 3
	fi
fi

# Unzip and move
output_file_dir=`dirname ${output_file}`
unzip -q ${output_file} -d ${output_file_dir}
if [ $? -ne 0 ]; then
	rm -rf ${output_file_dir}/chrome-mac 
	echo "Unzipping failed. Sorry :("
	exit 1
fi

# Nuke existing application dir if any
if [ -d /Applications/Chromium.app ]; then
	rm -r /Applications/Chromium.app
fi

# Move
mv ${output_file_dir}/chrome-mac/Chromium.app /Applications

# Clean our cruft
rm -r ${output_file_dir}/chrome-mac

# Voila!
echo "Done! Enjoy your new shiny Chromium."
open /Applications/Chromium.app
