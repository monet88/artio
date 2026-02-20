---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: ImagePickerNotifier >10MB Rejection Test

## Objective
Close the 🔴 audit gap from UI & Concurrency Polish milestone: add a unit test proving that `ImagePickerNotifier.pickImage()` rejects files exceeding 10MB and sets the correct error message.

## Context
- lib/features/create/presentation/providers/image_picker_provider.dart
- The `pickImage()` method checks `file.length() > _maxFileSize` (10 * 1024 * 1024) and sets error state
- No existing test file for this provider — must create from scratch
- Uses `image_picker` package (needs mock for `ImagePicker`) and `dart:io` `File` (needs mock for `File.length()`)

## Tasks

<task type="auto">
  <name>Create ImagePickerNotifier unit tests</name>
  <files>test/features/create/presentation/providers/image_picker_provider_test.dart</files>
  <action>
    Create a new test file covering these scenarios:

    1. **pickImage with file >10MB sets error state** — Mock `ImagePicker.pickImage()` to return an `XFile`, mock `File(path).length()` to return `11 * 1024 * 1024`. Assert `state.error` equals `'Image is too large. Maximum size is 10MB.'` and `state.pickedImage` is null.

    2. **pickImage with file ≤10MB sets pickedImage** — Mock file length to return `5 * 1024 * 1024`. Assert `state.pickedImage` is not null and `state.error` is null.

    3. **pickImage when user cancels (returns null)** — Mock `pickImage` to return null. Assert state unchanged.

    4. **pickImage when exception thrown sets error** — Mock `pickImage` to throw. Assert `state.error` starts with `'Failed to pick image:'`.

    Use `mocktail` for mocking. Note: `ImagePickerNotifier` creates `ImagePicker` internally, so you may need to refactor the constructor to accept an `ImagePicker` parameter (with default for production) to enable injection in tests. Similarly for `File` — consider wrapping `File(path).length()` in a testable way, or use `IOOverrides` to mock file system access.

    **Approach for mocking File.length():**
    - Use Dart's `IOOverrides` to intercept `File` creation in tests, OR
    - Add an optional `fileLengthGetter` callback parameter to `ImagePickerNotifier` for testing only.
    - Prefer IOOverrides as it avoids production code changes.

    **Do NOT:**
    - Add unnecessary abstractions beyond what's needed for testing
    - Change the public API of ImagePickerNotifier
  </action>
  <verify>flutter test test/features/create/presentation/providers/image_picker_provider_test.dart</verify>
  <done>All 4 test cases pass. The >10MB rejection path is covered by an automated test.</done>
</task>

<task type="auto">
  <name>Run full test suite and analyzer</name>
  <files>N/A</files>
  <action>
    Run `flutter test` (full suite) and `flutter analyze` to ensure no regressions.
  </action>
  <verify>flutter test && flutter analyze</verify>
  <done>All existing tests pass. Zero analyzer issues.</done>
</task>

## Success Criteria
- [ ] Test file exists at `test/features/create/presentation/providers/image_picker_provider_test.dart`
- [ ] >10MB rejection path is tested with assertion on error message
- [ ] All tests pass (existing + new)
- [ ] Zero analyzer issues
