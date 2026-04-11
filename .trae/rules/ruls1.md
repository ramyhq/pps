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
- **Rule**: Keep models explicit and readable: write manual `fromJson/toJson` (no generated `*.g.dart`).

## 6. Immutable State

- All state classes must be immutable.
- Use `equatable` or `freezed` to implement value equality.
- **Rule**: Fields in state classes must be `final`.

## 7. Localization (i18n)

- The app is multi-language ready from day one.
- **Rule**: Do not hardcode strings in UI widgets. Use `AppLocalizations` (setup pending) or a constants file for now, transitioning to `.arb` files.

## 8. Repository Pattern

- Separate Data Layer from Domain/UI Layer.
- **Rule**: Keep it simple by default: Provider calls a feature RemoteDataSource directly.
- Use a Repository only when the feature is complex enough to justify it (aggregation, multiple sources, heavy mapping).

## 9. API & Networking

- Use `Dio` (recommended) or `http` client.
- Implement Interceptors for:
    - Auth Token injection.
    - Global Error handling (401, 500).
    - Logging.

## 9.1 Supabase Schema Discipline (Mandatory)

- قبل ربط أي شاشة/Dropdown ببيانات Supabase، لازم يتم تأكيد الجداول والأعمدة الفعلية داخل schema `public` (عن طريق `information_schema` أو SQL Editor) وعدم افتراض أسماء جداول غير موجودة.
- في هذا المشروع حاليًا مصدر قائمة الخدمات/الأنواع هو جدول `reservation_service_types` (الأعمدة: `key`, `label`, `code`) وليس `general_services`.

## 10. Models (No Generators)

- **Rule**: Prefer one explicit model per feature (manual `fromJson/toJson`) over DTO + generated files.
- **Rule**: Do not add `*.g.dart` codegen for new work unless explicitly requested.

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

## 14.1 Response Formatting (Arabic/Egyptian)

- الرد يكون منسق وسهل القراءة باستخدام عناوين قصيرة وبنود `-`.
- ابدأ دائمًا بـ **الخلاصة** ثم **السبب** ثم **الحل** ثم **الخطوات المطلوبة منك**.
- استخدم كلمات واضحة وقصيرة، وقلل الحشو.
- لما يكون فيه مشكلة متعلقة بقاعدة البيانات: اذكر (الجدول/العمود/السياسات RLS) بشكل مباشر.
- لو فيه كود اتغير: اذكر الملفات/المسارات الأساسية فقط بدون تفصيل زائد.

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

- Any feature that persists or reads backend data MUST follow this order:
  1) `features/<feature>/data/models` (explicit model + `fromJson/toJson`).
  2) `features/<feature>/data/data_sources` (direct Supabase/API access only).
  3) `features/<feature>/provider` (Riverpod provider/notifier uses the RemoteDataSource).
  4) `features/<feature>/ui` (widgets call provider only).
- Rules:
  - No API calls in UI widgets.
  - No generated code for new data models (`*.g.dart`) unless explicitly requested.
  - DataSource throws typed exceptions; Provider converts them to user-friendly logs/states.
