Developer notes

- Regenerating Hive adapters
  - This project uses Hive type adapters for `StudyPlan`, `Question`, `Subtopic`, and `Flashcard`.
  - To regenerate adapters run locally:

```bash
# from project root
flutter pub run build_runner build --delete-conflicting-outputs
```

- Migration
  - `lib/utils/migration_runner.dart` provides non-destructive migrations to convert legacy `List<String>` shapes into `Question` and `Subtopic` objects.
  - `main.dart` now opens the `studyPlans` box and runs `MigrationRunner.migrateStudyPlans()`; it will show an initialization error screen if the box cannot be opened.

- Tests
  - New unit test at `test/migration_runner_unit_test.dart` validates the migration of simple legacy shapes.
  - Run tests locally with:

```bash
flutter test
```

- TODOs remaining
  - Add more exhaustive migration tests covering nested subtopics and map-shaped legacy objects.
  - Regenerate adapters via build_runner and ensure generated adapters are checked in.
  - Add integration tests for Study Mode & Revision flows.

