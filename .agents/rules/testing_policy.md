# Testing Policy for Future Developments

For all new features, bug fixes, refactoring, and future developments in this project:
1. **Always Include Comprehensive Tests**:
   - Write positive test cases (verifying the happy path and expected behavior).
   - Write negative test cases (verifying error handling, invalid inputs, failure responses).
   - Write edge cases (boundary values, empty collections, limits, null/empty strings, tied scores, timeout/delays).
2. **Use Mock Data**:
   - Keep tests isolated, fast, and deterministic using mock data and fakes.
   - Do not rely on real network calls in tests.
3. **Continuous Verification**:
   - Always run `flutter test` after adding tests to verify all test suites pass with zero failures.
