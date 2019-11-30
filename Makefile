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
		-destination platform="iOS Simulator,name=iPhone 11,OS=13.2.2" \
		| xcpretty
