# Package Pricing System PPS — System Design

## 1) Overview
PPS هو تطبيق Flutter لنظام تسعير الباقات السياحية، يعمل على الويب والموبايل. الهدف هو بناء نظام قابل للتوسع بواجهة موحدة، مع فصل صارم بين واجهة المستخدم والمنطق والبيانات.

## 2) Architecture
### 2.1 Layers
التطبيق مبني على Feature-first:
- `core/`: مكونات مشتركة على مستوى التطبيق (theme, localization, router, shared widgets).
- `features/<feature>/data`: Models/DTOs + Repositories + Services.
- `features/<feature>/provider`: State/Controllers (Riverpod).
- `features/<feature>/ui`: Screens + Widgets (عرض فقط).

### 2.2 State Management
- Riverpod هو المصدر الوحيد للحالة والـ DI.
- أي منطق أعمال (Business Logic) يجب أن يكون داخل `provider/`.
- الـ UI يتعامل مع state فقط (watch/read) ولا يحتوي عمليات حساب/تحويل/تجهيز بيانات.

### 2.3 Navigation
GoRouter هو المصدر الوحيد للمسارات.
- يتم استخدام `ShellRoute` لعرض Layout ثابت:
  - Sidebar (يسار)
  - Header (أعلى)
  - Child (محتوى الشاشة)

## 3) App Composition
### 3.1 Entry
- `lib/main.dart`
  - `ProviderScope`
  - `MaterialApp.router`
  - `supportedLocales`: `en`, `ar`

### 3.1.1 Auth (RMS)
- Route: `/login`
- GoRouter redirect: أي مسار غير `/login` يتطلب session ناجحة (حد أدنى: `rmsSessionProvider.isAuthenticated`).

### 3.2 Router Map
- Root:
  - `/login`
  - `/reservations`
    - `/reservations/details`
    - `/reservations/create-general`
    - `/reservations/create-agent`
    - `/reservations/create-transportation`
  - Redirects:
    - `/create-agent` → `/reservations/create-agent`
    - `/create-general` → `/reservations/create-general`
    - `/create-transportation` → `/reservations/create-transportation`
    - `/details` → `/reservations/details`

## 4) Core Modules
### 4.1 Theme
- Location: `lib/core/theme/theme_provider.dart`
- Strategy:
  - ThemeData واحد منظم ومشترك.
  - أي توسعة مستقبلية (dark mode / density / typography) تكون عبر provider.

### 4.2 Localization
- Location: `lib/core/localization/locale_provider.dart`
- Strategy:
  - Locale موحدة على مستوى التطبيق.
  - تجهيز لدعم ملفات ARB لاحقًا.

### 4.3 Shared Widgets
- Location: `lib/core/widgets`
- Includes:
  - `Sidebar`
  - `Header`
  - `CustomFormFields`
  - `ScaffoldWithSidebar`

## 5) Feature: Reservations
### 5.1 UI Screens
- Location: `lib/features/reservations/ui/screens`
- Screens:
  - ReservationListScreen
  - ReservationDetailsScreen
  - CreateGeneralServiceScreen
  - CreateAgentReservationScreen
  - CreateTransportationServiceScreen

### 5.1.1 Reservation List Composition
- `ReservationListScreen` يعرض جدولًا رئيسيًا للحجوزات مع صف قابل للتمدد لكل حجز.
- عند التمدد، يتم تحميل `reservationDetailsProvider` ثم تقسيم `services` إلى مجموعتين بصريتين:
  - `ReservationServiceType.agent` داخل مجموعة مستقلة بعنوان `Hotel direct`
  - `ReservationServiceType.general` و`ReservationServiceType.transportation` داخل مجموعة مشتركة بعنوان `Services`
- مجموعة الفنادق تملك Header خاص بالفنادق، بينما المجموعة المشتركة تستخدم Header موحد يناسب الخدمات العامة والمواصلات.
- كل مجموعة تنتهي بصف إجمالي خاص بها، ثم يتم عرض `Grand total` مجمع لكل الخدمات داخل الحجز.
- زر التعديل داخل كل صف خدمة يوجّه مباشرة إلى شاشة التعديل المناسبة حسب `ReservationServiceType`.
- العنوان والوصف في الصفوف لم يعدا ثابتين؛ يتم اشتقاقهما من `payload` الفعلي لكل خدمة:
  - `Agent Direct`: اسم الفندق + بيانات الغرفة/الوجبة/PAX
  - `General service`: `General service - <serviceName>`
  - `Transportation`: المسار أو أول Trip route + إجمالي الكمية من الرحلات

### 5.1.2 Reservation Details Composition
- `ReservationDetailsScreen` يبني Accordion مستقل لكل خدمة اعتمادًا على `ReservationServiceSummary`.
- بيانات `Agent Direct` و`Transportation` في الـsummary/body تُقرأ من Domain details الناتجة من الـpayload، وليس من قيم placeholder ثابتة.
- قسم `Transportation` يعرض قائمة Trips ديناميكية مع sale/cost لكل Trip محسوبة من `salePerItem/costPerItem × quantity`.
- Header الخدمة يعرض عنوانًا وصفيًا مع `displayNo` ووسم النوع (`Agent Direct`) عند الحاجة.

### 5.2 Providers
- `create_agent_reservation_provider`:
  - إدارة حالة شاشة `CreateAgentReservationScreen` كاملة (Dates, Nights, Room rates, Summary)
  - تطبيق قواعد الحساب المالي باستخدام `Decimal`
  - إدارة إضافة/حذف الغرف وحساب `PAX` و`Total RN`
  - تنفيذ تدفق الحفظ إلى Supabase مع حالات `isSaving` ونتيجة الحفظ
- `reservations_data_providers`:
  - حقن `ReservationsRemoteDataSource` و`ReservationsRepository` عبر Riverpod
- `reservations_list_provider`:
  - تحميل البيانات
  - إدارة الفلاتر
  - البحث والصفحات (pagination)
- `reservation_details_provider`:
  - تحميل تفاصيل الحجز
  - إدارة الإجراءات (actions) لاحقًا

### 5.3 Data Layer
- `AgentReservationDraft` (Domain model)
- `CreateAgentReservationPayloadDto` + generated mapping (`json_serializable`)
- `ReservationsRepository` (واجهة)
- `ReservationsRepositoryImpl` (تنفيذ)
- `ReservationsRemoteDataSource` (Supabase tables: `reservation_orders`, `reservation_services`, `reservation_service_types`)
  - `reservation_services`: يعتمد على `service_type` + `payload` (JSON) لحفظ تفاصيل كل خدمة
  - `reservation_service_types`: قاموس أنواع/خدمات النظام (الأعمدة: `key`, `label`, `code`)
- `ReservationServiceSummary` أصبح يحمل تفاصيل typed اختيارية لكل نوع خدمة:
  - `agentDetails`
  - `generalDetails`
  - `transportationDetails`
- `ReservationsRepositoryImpl` يقوم بفك `payload` حسب `service_type` وتحويله إلى Domain draft مناسب لإعادة الاستخدام في:
  - قائمة الحجوزات
  - شاشة تفاصيل الحجز
  - شاشات التعديل
- مرجع التوثيق الوظيفي للحسابات الحالية داخل الحجوزات موجود في الملف `reservations_calculations.md`.
- الأسطر الحسابية الأساسية داخل provider/screens/repository موثقة inline بتعليقات تبدأ بـ `//CALCULATIONS` لتسهيل التتبع والصيانة.

### 5.4 Backend Integration
- Supabase initialization في `core/supabase/supabase_client_provider.dart`.
- التهيئة تعتمد على:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- إذا لم يتم تمرير القيم، التطبيق يعمل UI-first بدون crash، لكن حفظ الحجز يرجع رسالة خطأ واضحة.

## 6) Data Flow (Target)
UI (screens/widgets) → Provider (Notifier/Controller) → Repository → Remote/DataSource → DTO → Repository maps to Domain → Provider updates state → UI renders

## 7) Responsive Strategy
- يعتمد على Layout ثابت للويب (Sidebar/Header) مع محتوى قابل للتمرير.
- عند إضافة نسخة Mobile UI:
  - نقل Sidebar إلى Drawer أو Bottom Navigation حسب التصميم.
  - استخدام `LayoutBuilder` لتبديل layout حسب العرض.

## 8) Error Handling (Target)
- Failure model موحد داخل `core` أو داخل feature حسب الحاجة.
- في الواجهة: عرض رسائل واضحة للمستخدم.
- في الخلفية: تسجيل (logging) قابل للتوسعة.

## 9) UI Standards
- **Page Spacing (Create Screens)**:
  - Page padding: 16
  - Card body padding: 16
  - Section gap: 16
  - Field horizontal gap: 12
- **Card Design**:
  - `elevation: 0`, `shape: RoundedRectangleBorder(borderRadius: 8, side: BorderSide(color: AppColors.border))`
  - Header: `AppColors.light` background, `AppColors.primary` text (13px, w600) في الشاشات الكومباكت.
- **Buttons**:
  - Primary: `ElevatedButton`, Color `#198754`, White text, Radius 4.
  - Secondary: `OutlinedButton`, Color `#198754`, Radius 4.
- **Grids/Tables**:
  - Headers: `#EAF3FF` (Light Blue) for compact tables.
  - Borders: `#D5DEEE` للشبكات والجداول.
  - Typography: أحجام 11px–12px داخل الجداول لضبط الكثافة البصرية.
  - Reservation list expanded rows: تقسيم داخلي حسب نوع الخدمة مع banner لكل مجموعة وصفوف totals مستقلة قبل الإجمالي النهائي.

### 9.1 Create Screens Visual System (Baseline)
المرجع البصري الأساسي لشاشات الإنشاء داخل Reservations هو `CreateAgentReservationScreen`، وأي شاشة إنشاء جديدة (مثل `CreateGeneralServiceScreen`) لازم تتبع نفس التوكنز التالية لضمان هوية واحدة:

- **Spacing Tokens**:
  - Page padding: 16
  - Card header padding: 16
  - Card body padding: 16
  - Row gap (horizontal): 12
  - Section gap (vertical): 16
- **Typography**:
  - Screen title: `AppTextStyles.heading` (18px / w600)
  - Field label: `AppTextStyles.label` (11px / w500)
  - Field text/value: 12px
- **Buttons (Primary Actions: Save / Save & New / Save And New)**:
  - `ElevatedButton.icon`
  - Background: `#198754`
  - Foreground: White
  - Border radius: 4
  - Padding: horizontal 20, vertical 12
  - Icon size: 16
  - Button spacing: 8
- **Buttons (Inline Actions مثل Add/Clear في الشاشات التي تحتوي Grid)**:
  - Height: 32 (via `minimumSize`)
  - Text size: 12
  - Icon size: 12
  - Padding: horizontal 16, vertical 8
  - Primary background: `#198754`
  - Outlined border: `#198754`
- **Desktop Field Width Tokens (Reservation details)**:
  - `clientWidth`:
    - >= 1450: 380
    - >= 1200: 340
    - else: 300
  - `arrivalWidth`:
    - >= 1450: 280
    - >= 1200: 250
    - else: 220
  - `nightsWidth`:
    - >= 1200: 90
    - else: 78

### 9.2 Global Design Tokens (Mandatory)
المصدر الرسمي لثوابت المقاسات/الـTypography/الـRadii/الـSpacing هو:
- `lib/core/constants/app_colors.dart` (AppColors + AppTextStyles + Design Tokens)

#### Typography (Font Sizes)
استخدم هذه القيم بدل كتابة `fontSize` كأرقام في الواجهات الجديدة:
- `AppFontSizes.title20`: عنوان شاشة التفاصيل في الـToolbar.
- `AppFontSizes.title14`: عنوان Dialog (مثل Edit Info).
- `AppFontSizes.title13`: عنوان Accordion/Card header.
- `AppFontSizes.body12`: نصوص القيمة/الـbody في الـUI المضغوط.
- `AppFontSizes.label11`: Labels + meta text + نصوص الـActions الصغيرة.
- `AppFontSizes.badge10`: نصوص الـBadges/Chips الصغيرة.

متى نستخدمها:
- استخدم `label11` للـLabels فقط (Res. ID/Creator/Date) أو نصوص ثانوية.
- استخدم `body12` لأي قيمة أو نص أساسي داخل Cards.
- استخدم `title13` لعناوين الأقسام داخل Cards (Accordion header).
- استخدم `title20` لعنوان الصفحة الرئيسي في أعلى الشاشة.

#### Spacing (Gaps & Paddings)
استخدم `AppSpacing` لكل `SizedBox` و`EdgeInsets`:
- `AppSpacing.s4/s6/s8`: مسافات صغيرة داخل صف واحد.
- `AppSpacing.s10/s12/s14`: مسافات قياسية بين عناصر/أقسام داخل Card.
- `AppSpacing.s16/s20/s24`: مسافات كبيرة بين أقسام رئيسية أو بين Cards.

ثوابت جاهزة للاستخدام المباشر:
- `AppInsets.pageDetails`: Padding موحد لشاشات Details (مثل ReservationDetailsScreen).
- `AppInsets.cardBody10`: Padding موحد لمحتوى Cards المضغوطة.
- `AppInsets.sectionHeader`: Padding موحد لهيدر الأقسام داخل Card.
- `AppInsets.accordionHeader` / `AppInsets.accordionBody`: Padding موحد للـAccordion.
- `AppInsets.inputContent`: Padding موحد لداخل حقول الإدخال (InputDecoration.contentPadding).

#### Radii (Rounded Corners)
استخدم `AppRadii` بدل `BorderRadius.circular(<number>)`:
- `AppRadii.r3`: Pills/Chips الصغيرة.
- `AppRadii.r4`: Controls + Buttons + Card radius في الـUI المضغوط.
- `AppRadii.r6`: Accordions + Dialog radius في تفاصيل الحجز.
- `AppRadii.r8`: Menu item hover containers.
- `AppRadii.r12`: Popup menus.

#### Heights & Icon Sizes
استخدم الثوابت دي لتوحيد كثافة الواجهة:
- `AppHeights.button32`: ارتفاع أزرار التولبار/الديلوج (minimumSize: 32).
- `AppHeights.field34`: ارتفاع input مضغوط (standard).
- `AppHeights.menuItem40`: ارتفاع عنصر menu.
- `AppHeights.chip16`: ارتفاع badge/chip.
- `AppHeights.iconButton24/iconButton28`: أحجام IconButton المدمجة.
- `AppIconSizes.s12/s13/s14/s16/s18`: أحجام الأيقونات القياسية.

#### Motion & Effects
- `AppDurations.accordion`: مدة animations الصغيرة داخل accordions.
- `AppAlphas.surface15`: شفافية خلفيات pills/chips.
- `AppAlphas.hover08`: hover بسيط فوق أزرار primary.
- `AppAlphas.hover26`: hover خلفية عامة.
- `AppAlphas.shadow28`: shadow للـmenus.
- `AppAlphas.separator35`: شفافية separators.
- `AppElevations.menu`: elevation للـpopup menus.

#### Breakpoints (Responsive)
استخدم `AppBreakpoints` بدل أرقام ثابتة:
- `AppBreakpoints.detailsDesktop`: بداية Layout الديسكتوب في شاشة تفاصيل الحجز.
- `AppBreakpoints.dialogMd` / `AppBreakpoints.dialogLg`: تقسيمات dialog layout.

#### Reservation Details Layout Widths
ثوابت widths المستخدمة في شاشات تفاصيل الحجز:
- `ReservationDetailsLayout.mainInfo*Width`: widths لحقول Main Info في وضع Wrap.
- `ReservationDetailsLayout.serviceColumn*`: widths لأعمدة معلومات الخدمة.
- `ReservationDetailsLayout.roomTypeCol/priceCol/totalCol`: widths لأعمدة جدول Room details.
- `ReservationDetailsLayout.editDialog*`: قياسات dialog (maxWidth/height ratio/min height + field widths).
- `ReservationDetailsLayout.actionsMenu*`: قياسات actions menu (min/max/extra/divider).

قاعدة إلزامية:
- أي شاشة جديدة أو تعديل UI لا يستخدم Tokens → يعتبر مخالف للنظام الموحد.

## 10) Update Policy (Mandatory)
- هذا الملف و `project_context.md` يجب تحديثهما مع كل تغيير مهم:
  - إضافة/تعديل Feature
  - إضافة/تعديل Screen أو Route
  - تغييرات على core (theme/localization/router/shared widgets)
  - تغييرات معمارية

## 11) Change Log
### 2026-03-17
- توثيق مخطط Supabase الحالي في schema `public`: `clients`, `hotels`, `reservation_orders`, `reservation_service_types`, `reservation_services`, `suppliers`.
- اعتماد `reservation_service_types` كمصدر رسمي لقائمة الخدمات/الأنواع بدل جدول غير موجود (`general_services`) وربط حقل Service في شاشة Create General Service به.
- تحديث `ReservationDetailsScreen` لتقارب التصميم المرجعي (Toolbar + Card واحدة + Accordions + Totals).
- إصلاح سلوك زر Apply داخل `Room details` لضمان انعكاس قيم التطبيق على صفوف الأيام في وضع non-manual.
- حذف الحقول غير المطلوبة من صفحة `CreateAgentReservationScreen` أسفل الجدول (Room/Voucher/Reference/Remarks/Agreement).

### 2026-03-15
- إضافة `AppColors.actionGreen` واعتمادها كلون موحد لأزرار الحفظ في شاشات الإنشاء.
- تحديث تقويم `CustomDatePickerField` ليعرض عنوان الشهر/السنة كـ `Mar 2026` مع أسهم تنقل فقط (نمط مضغوط موحد).
- إضافة `SegmentedTimePicker` كحقل وقت موحد (Overlay spinner) واعتماده في شاشة Transportation.
- تحديث `CustomDropdown` لتوحيد لون العنصر المحدد بخلفية `AppColors.primary` بالكامل.
- تصغير Typography الموحدة (Label 11 / Value 12) وتقليل خط الـ Sidebar لمطابقة التصميم.
- تحديث شاشة `CreateTransportationServiceScreen`:
  - حذف الحقول: Related to hotel reservation / Conf. No / Detail remarks / Agreement No.
  - حذف خيارات VAT: Prices do not include VAT / Don't apply VAT to cost.
  - إعادة بناء جدول تسعير Sale/Cost بألوان/حدود مضغوطة مثل الصور مع حساب Price/Total باستخدام `Decimal`.
  - توحيد شكل عنوان `Trip (#T-1)` ليكون بدون خلفية (شفاف) مع أيقونة زرقاء ونص أزرق.
  - اعتماد Grid مخصص لـ Desktop يطابق الصورة حرفيًا: (Type/Date), (From/Time), (Place/Vehicle), (To/Qty+Pax), (Place/Notes).
  - استخدام `SegmentedTimePicker` مع hint `22:22` و `CustomDatePickerField` مع hint `dd/MM/yyyy`.
  - زر `+ Add` كنص بسيط أسفل البطاقات على اليمين.

### 2026-03-14
- توحيد الهوية البصرية لشاشة `CreateGeneralServiceScreen` لتطابق `CreateAgentReservationScreen` (مقاسات الحقول والمسافات وألوان أزرار الحفظ).
- توحيد مقاسات وتباعدات شاشة `CreateGeneralServiceScreen` لتطابق `CreateAgentReservationScreen` واعتماد نفس نظام أعمدة HTML الأصلي (Desktop + Responsive fallback).
- تنفيذ Data Layer فعلي لميزة `CreateAgentReservation` (Domain/DTO/Repository/RemoteDataSource) وربطه بـ Supabase.
- إضافة `supabase_flutter` إلى dependencies وتفعيل تهيئة Supabase في `main.dart`.
- ربط زر `Save` و`Save & New` في `CreateAgentReservationScreen` بتدفق حفظ حقيقي عبر provider.
- إنشاء `create_agent_reservation_provider` داخل `lib/features/reservations/provider` ونقل منطق الأعمال من الشاشة إليه.
- تحويل `CreateAgentReservationScreen` إلى `ConsumerStatefulWidget` لتبقى الواجهة Presentation-only مع استدعاء provider للأحداث.
- اعتماد State immutable داخل provider (`CreateAgentReservationState`) مع نماذج بيانات (`RoomDayRate`, `AddedRoomSummary`) منفصلة عن UI.
- تحديث اختبار Widget لشاشة الإنشاء للعمل تحت `ProviderScope` والتحقق من تدفق زر `Add` بعد إعادة الهيكلة.

### 2026-03-12
- تأسيس Riverpod + GoRouter + Shell layout.
- إعادة تنظيم الملفات إلى core/features.
- تحديث initialLocation وإضافة redirects لمسارات مختصرة.
- تحديث UI صفحة `CreateAgentReservationScreen` وحذف الحقول غير المستخدمة.
- إزالة الحقول الإضافية (Terms, Manual Rate, Adults, Voucher) من واجهة `CreateAgentReservationScreen`.
- حذف أقسام (Payment, Attachments, Extra Details) وتعديل تسمية الحقول في `CreateAgentReservationScreen`.
- إعادة تصميم `CreateAgentReservationScreen` لمطابقة تصميم UI قياسي جديد (Grid, Colors, Buttons).
- تحسين قسم `Room details` في `CreateAgentReservationScreen` ليتطابق مع النظام الأصلي (إزالة خيار VAT الإضافي، ضبط الأعمدة، وتقليل المسافات والأحجام).
- إعادة تنفيذ قسم `Room details` اعتمادًا على بنية HTML الأصلية: Sale/Cost grid مزدوجة، صفوف أيام كاملة، وإظهار خياري `Is manual rate` و`Prices do not include VAT`.
- تثبيت قياسات حقول الصف العلوي في `Room details` بقيم تصميمية دقيقة (32px height، 6px label spacing، 11–12px typography) لتحقيق تطابق بصري أدق مع النظام الأصلي.
- إضافة مكوّن تاريخ عام `CustomDatePickerField` ضمن `core/widgets/custom_form_fields.dart` يعمل بـ OverlayEntry مع تقويم أحادي مطابق لتخطيط الـHTML المرجعي (اختيار شهر/سنة، أسهم تنقل، شبكة أيام Monday-first) واعتماده كنمط موحد لحقول التاريخ في واجهات الإنشاء.
- اعتماد نسخة compact من `CustomDatePickerField` لتقريب visual scale من النظام الأصلي: عرض popup أصغر غير مرتبط بعرض الحقل، وتخفيض heights/typography/spacing داخل الحقل والتقويم، مع تصغير paddings العامة في شاشة `CreateAgentReservationScreen`.
- تطبيق مستوى compact أكثر تشددًا في `CustomDatePickerField`: تقليص popup width إلى 300، تقليل header controls إلى عناصر مدمجة غير معتمدة على `IconButton`، ضغط شبكة الأيام، وتقليل ارتفاع input إلى 34 لتحقيق scale مطابق تقريبًا للنظام الأصلي.
- تحديث `CreateAgentReservationScreen` لاستخدام `LayoutBuilder` في `Reservation details` وتفعيل نمط عروض ثابتة على Desktop للحقول الحرجة (`Arrival date`, `Nights`, `Departure date`, `Client`, `Hotel`) مع fallback مرن للشاشات الأصغر للحفاظ على الاستجابة.
- تحسين `CustomDatePickerField` بإضافة دعم `MouseRegion` لخلايا الأيام في الـoverlay calendar بحيث يتم تطبيق hover state مرئي (خلفية فاتحة + لون نص primary) للخلايا القابلة للاختيار.
- تحديث `CustomDropdown` في `core/widgets/custom_form_fields.dart` ليعمل كـ Overlay searchable dropdown عام بدل `DropdownButtonFormField` التقليدي، مع search input داخلي، فلترة فورية، وتنسيق مضغوط متوافق مع واجهات الحجز.
- تعديل توزيع حقول `Reservation details` في `CreateAgentReservationScreen` بنمط Desktop: استبدال موضع `Hotel` بـ `Client option date`، ثم عرض `Hotel` في صف منفصل، وضبط `Supplier` بعرض ثابت مساوي لعرض `Hotel` للحفاظ على الاتساق البصري.
- إضافة سلوك UI ديناميكي في `CreateAgentReservationScreen` لاحتساب عدد الليالي من `Arrival date` و`Departure date` وتوليد صفوف يومية داخل شبكة `Room details` وفق تاريخ كل ليلة.
- تحديث شبكة `Room details` لدعم نمطين إدخال: `Manual rate` (إدخال يومي مباشر في كل صف) و`Apply mode` (إدخال علوي مرة واحدة ثم نسخ القيم لكل الليالي عبر زر `Apply`).
- ربط حقل `Nights` في `Reservation details` كتدفق ثنائي الاتجاه مع التواريخ: تعديل الليالي يدويًا يُعيد حساب `Departure date` مباشرة مع إعادة توليد الصفوف اليومية.
- تحسين تجربة الإدخال داخل خلايا `Room details` بإزالة إعادة البناء المتكررة أثناء الكتابة للحفاظ على التركيز داخل الحقل.
- تحويل عناصر الصف العلوي في `Room details` إلى عناصر تفاعلية فعلية: إدخال رقمي لـ `No. of rooms` وقائمتين اختيار لـ `Room type` و`Meal plan`.
- تفعيل دورة إضافة الغرف في `Room details`: زر `Add` يُنشئ عنصرًا في جدول الملخص مع `No. Of Rooms`, `Total RN`, `Room Type`, `Meal Plan`, `Total Sale`, `Total Cost` وعمود إجراءات للحذف.
- اعتماد حساب `PAX` ديناميكيًا من نوع الغرفة وعددها داخل شاشة الإنشاء، مع تغذية حقول الملخص السفلية (`No. of adults`, `PAX`) مباشرة من الإجمالي الحالي.
- استخدام `decimal` في حسابات إجمالي البيع والتكلفة الخاصة بملخص الغرف لتفادي أخطاء الدقة العشرية.
