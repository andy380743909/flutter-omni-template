# Makefile — convenience targets for the Flutter app template.
# Most targets simply wrap `flutter`/`dart` commands so the whole team uses
# the same invocations.

.PHONY: bootstrap get analyze format test test-int ci clean

## bootstrap: generate native platform directories (see scripts/bootstrap.sh)
bootstrap:
	bash scripts/bootstrap.sh

## get: fetch dependencies
get:
	flutter pub get

## analyze: static analysis (zero warnings required)
analyze:
	flutter pub get
	dart analyze

## format: format all Dart sources
format:
	dart format .

## test: run unit + widget tests
test:
	flutter test

## test-int: run integration tests (needs a device/emulator)
test-int:
	flutter test integration_test

## ci: what the PR gate runs locally
ci: analyze test

## clean: remove build artifacts
clean:
	flutter clean
