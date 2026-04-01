You are an expert Flutter developer working on the RMS Clone project.
You must follow these strict architectural guidelines and best practices.

# RMS Clone - Architecture & Best Practices

## 1. Project Structure (Feature-First)

We follow a **Feature-First** architecture. Each major business domain is a separate feature.

```
lib/
├── core/                   # Global/Shared code
│   ├── constants/          # Colors, text styles, api endpoints
│   ├── router/             # GoRouter configuration
│   ├── theme/              # Theme data & providers
│   ├── localization/       # Localization setup
│   ├── widgets/            # Globally shared widgets (buttons, inputs)
│   └── utils/              # Helper functions, formatters
│
├── features/               # Business Features
│   ├── reservations/       # Feature Name
│   │   ├── data/           # Repositories, API services, Models (DTOs)
│   │   ├── provider/       # State Management (Riverpod providers)
│   │   └── ui/             # UI Layer
│   │       ├── screens/    # Full page widgets
│   │       └── widgets/    # Feature-specific widgets
│   └── ...
│
└── main.dart               # App entry point
```

## 2. State Management (Riverpod)

- Use **Riverpod** for all state management and dependency injection.
- Prefer `AsyncNotifierProvider` or `StateNotifierProvider` (legacy) for complex state.
- Keep UI logic out of widgets; move it to Controllers/Notifiers.
- **Rule**: Never use `setState` for business logic. Only for purely ephemeral UI state (like animation controller).

## 3. Navigation (GoRouter)

- Use **GoRouter** for all navigation.
- Define routes in `lib/core/router/app_router.dart`.
- Use `ShellRoute` for persistent UI elements (Sidebar, Header).
- **Rule**: Do not use `Navigator.push` directly.

## 4. Financial Calculations (Decimal)

- **CRITICAL**: Never use `double` for money or precise calculations. Floating point errors will occur.
- **Rule**: Use the `decimal` package for all monetary values.
- Example: `Decimal.parse('10.99') + Decimal.parse('5.00')`.

## 5. Type Safety

- **Rule**: Avoid `dynamic` at all costs. Use strict types.
- **Rule**: Use `built_value` or `freezed` or `json_serializable` for data models to ensure type-safe JSON parsing.

## 6. Immutable State

- All state classes must be immutable.
- Use `equatable` or `freezed` to implement value equality.
- **Rule**: Fields in state classes must be `final`.

## 7. Localization (i18n)

- The app is multi-language ready from day one.
- **Rule**: Do not hardcode strings in UI widgets. Use `AppLocalizations` (setup pending) or a constants file for now, transitioning to `.arb` files.

## 8. Repository Pattern

- Separate Data Layer from Domain/UI Layer.
- **Rule**: UI/Providers should never call API directly. They must call a `Repository`.
- Repositories return `Either<Failure, Success>` or throw custom Exceptions.

## 9. API & Networking

- Use `Dio` (recommended) or `http` client.
- Implement Interceptors for:
    - Auth Token injection.
    - Global Error handling (401, 500).
    - Logging.

## 9.1 Supabase Schema Discipline (Mandatory)

- قبل ربط أي شاشة/Dropdown ببيانات Supabase، لازم يتم تأكيد الجداول والأعمدة الفعلية داخل schema `public` (عن طريق `information_schema` أو SQL Editor) وعدم افتراض أسماء جداول غير موجودة.
- في هذا المشروع حاليًا مصدر قائمة الخدمات/الأنواع هو جدول `reservation_service_types` (الأعمدة: `key`, `label`, `code`) وليس `general_services`.

## 10. Data Transfer Objects (DTOs) vs Domain Models

- **Rule**: Separate API response models (DTOs) from the internal Domain models used by the UI.
- Map DTOs to Domain models in the Repository layer. This protects the app from backend schema changes.

## 11. Responsive Design

- The app runs on Web and Mobile.
- Use `LayoutBuilder` or `MediaQuery` to adapt UI.
- **Rule**: Test layouts on both desktop (wide) and mobile (narrow) resolutions.

## 12. Error Handling

- Centralize error handling.
- Use a generic `Failure` class for errors.
- Display user-friendly error messages, log technical details to a service (e.g., Sentry).

## 13. Theming & Styling

- Use `Theme.of(context)` for colors and text styles.
- Define custom colors in `AppColors` extension or class, but prefer mapping them to `ColorScheme`.
- **Rule**: Avoid hardcoded hex colors in widgets.

## 14. Code Style & Linting

- Follow strict Flutter lints (`flutter_lints`).
- **Rule**: Fix all linter warnings before committing.
- **Rule**: Use trailing commas for better formatting.

## 15. Testing

- Write **Unit Tests** for Repositories and Providers.
- Write **Widget Tests** for complex UI components.
- **Rule**: Critical business logic (calculations, validation) MUST be tested.

## 16. Documentation Discipline (Mandatory)

- `project_context.md` is the single quick overview of the project.
  - It MUST include a Changelog entry for any new/changed feature, screen, route, or core change.
- `system_design.md` is the single system design reference.
  - It MUST be updated whenever architecture, navigation, core modules, or feature boundaries change.
- Workflow rule:
  - Before implementing a new feature/screen/route, read `project_context.md` and `system_design.md`.
  - After implementing, update both files to reflect the new reality (and log the change).

## 17. Unified Data Layer Blueprint (Mandatory)

- Any feature that persists or reads backend data MUST follow this exact order:
  1) `features/<feature>/data/models` for app Domain models.
  2) `features/<feature>/data/dto` for request/response DTOs with `json_serializable`.
  3) `features/<feature>/data/data_sources` for direct Supabase/API access only.
  4) `features/<feature>/data/repositories` with interface + implementation.
  5) `features/<feature>/provider/*_data_providers.dart` for Riverpod DI wiring.
  6) Feature provider/notifier calls Repository only, never data source/client directly.
- Mapping rules:
  - DTO ↔ Domain mapping must be centralized in DTO factories or repository layer.
  - Never map raw JSON inside UI widgets.
- Error rules:
  - Data source/repository must throw typed/custom exceptions with clear messages.
  - Provider converts technical failures to user-facing states/messages.
- Reuse rule:
  - Any repeated backend flow in other features MUST reuse this same blueprint and naming style to keep the whole codebase consistent.
