// This integration test was intentionally moved out of the VM-run test path.
// The real test lives in `integration_tests/firestore_emulator_test.dart`.
//
// To run the emulator-backed integration test locally:
// 1) Add `integration_test` to dev_dependencies in your local environment (if needed).
// 2) Start Firebase emulators: `firebase emulators:start --only firestore,auth` from the repo root.
// 3) Run the test on a device/desktop target: `flutter test integration_tests/firestore_emulator_test.dart`.

// Placeholder file to avoid analyzer errors in CI when `integration_test` is not available.
