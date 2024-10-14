.PHONY: clean
clean:
	rm -rf .build .swiftpm Package.resolved || true

.PHONY: build-test
build-test:
	swift build

.PHONY: build-release
build-release:
	swift build --static-swift-stdlib -c release