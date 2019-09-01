test-macos:
	set -o pipefail && \
	xcodebuild test \
		-scheme ImageScout-macOS \
		-destination platform="macOS" \
		| xcpretty

test-ios:
	set -o pipefail && \
	xcodebuild test \
		-scheme ImageScout-iOS \
		-destination platform="iOS Simulator,name=iPhone XR,OS=12.2" \
		| xcpretty
