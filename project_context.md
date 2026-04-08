# Package Pricing System PPS — Project Context (Quick Overview)

## هدف المشروع
تطبيق Flutter لنظام تسعير الباقات السياحية (Package Pricing System - PPS)، يدعم الويب والموبايل، مع واجهة موحدة وقابلة للتوسع.

## نظرة سريعة
- **State Management**: Riverpod
- **Navigation**: GoRouter + ShellRoute (Layout ثابت: Sidebar + Header)
- **Architecture**: Feature-first
- **Feature Structure**: `data/` + `provider/` + `ui/`
- **Money/Financials**: Decimal فقط (ممنوع double)
- **Languages**: دعم مبدئي EN/AR (Locale provider)

## خريطة النظام (System Map)
### Core
- **Theme/Locale/Router**
  - Theme provider: `lib/core/theme`
  - Locale provider: `lib/core/localization`
  - Router: `lib/core/router`
- **Shared UI**
  - Sidebar/Header/shared widgets: `lib/core/widgets`

### Features
- **reservations**: `lib/features/reservations`
  - `ui/screens`
    - Reservation List
    - Reservation Details
    - Create General Service
    - Create Agent Reservation
    - Create Transportation Service
  - `provider`
    - `create_agent_reservation_provider.dart`: منطق شاشة إنشاء حجز الوكيل (تواريخ، Room rates، الإضافة/الحذف، الحسابات)
    - `reservations_data_providers.dart`: حقن DataSource/Repository عبر Riverpod
  - `data`
    - models: `agent_reservation_draft.dart`
    - dto: `create_agent_reservation_payload_dto.dart` (+ generated `*.g.dart`)
    - data_sources: `reservations_remote_data_source.dart` (Supabase)
    - repositories: `reservations_repository.dart` + `reservations_repository_impl.dart`

## حالة الميزات (Feature Status)
- **reservations**
  - UI: جاهز (Screens موجودة)
  - Provider: جزئي (تم تنفيذ Provider لشاشة Create Agent + save flow)
  - Data: جزئي (تم تنفيذ Data layer لحفظ Create Agent عبر Supabase)

## معيار موحد لبناء Data Layer (Template)
- أي ميزة جديدة تتبع نفس التسلسل وبنفس أسماء الطبقات:
  1) `data/models` لتمثيل Domain داخل التطبيق.
  2) `data/dto` لتمثيل payload/response وربط `json_serializable`.
  3) `data/data_sources` للتعامل المباشر مع Supabase فقط.
  4) `data/repositories` (interface + implementation) لعزل المصدر عن provider.
  5) `provider/*_data_providers.dart` لحقن DataSource/Repository عبر Riverpod.
  6) `provider/<feature>_provider.dart` يستدعي Repository فقط ولا يستدعي API مباشرة.
- قواعد إلزامية:
  - Mapping بين Domain و DTO يتم داخل repository أو dto factory فقط.
  - معالجة الأخطاء تكون Exception موحدة برسالة واضحة للمستخدم.
  - الحسابات المالية دائمًا بـ `Decimal` فقط.
  - نفس هذا الـTemplate يطبق على أي جزء متكرر لضمان توحيد أسلوب الكود في المشروع كله.

## سياسة التحديث (Mandatory)
- أي **Feature** جديدة، أو **Screen** جديدة، أو **Route** جديدة، أو تعديل في الهيكل/الثيم/اللغة:
  - لازم يتسجل في **سجل التغييرات** هنا.
  - ولازم يتحدث ملف `system_design.md` بما يتوافق.

## سجل التغييرات (Changelog)
### 2026-04-07
- تطوير `SegmentedTimePicker` كحقل وقت متقدم يدعم الإدخال المباشر للأرقام، التنقل بالأسهم، والتحويل التلقائي لصيغة 12 ساعة (مثال: 16 تتحول إلى 4 PM) واستبدال `CustomTimePickerField` به في شاشات الحجوزات.

### 2026-04-03
- إضافة ميزة `rms_auth` لاستهلاك Auth الخاص بـRMS عبر Dio (CSRF token + Session cookies) + شاشة `/login` وربط Redirect بسيط في GoRouter.

### 2026-03-25
- إضافة ملف توثيق شامل للحسابات داخل الحجوزات باسم `reservations_calculations.md` يشرح معادلات Agent/General/Transportation ومكان تنفيذها ومكان حفظها وإعادة تجميعها.
- إضافة تعليقات inline تبدأ بـ `//CALCULATIONS` داخل ملفات الحسابات الأساسية لتوضيح كل سطر مسؤول عن احتساب الليالي، PAX، RN، totals، وتجميعات القائمة/التفاصيل.

### 2026-03-24
- إصلاح تدفق تعديل `Agent Direct` بحيث يتم تحميل `Guest name` وبيانات `Hotel/Supplier` من الحجز/الخدمة الحالية وإعادة الحفظ كـ update على نفس الخدمة بدل إنشاء خدمة جديدة.
- إصلاح تدفق تعديل `CreateTransportationServiceScreen` لتحميل `Guest name`, `Terms & conditions`, `Transactions notes`, `Provider remarks`, `Provider option date` وبيانات المورّد والرحلات بالكامل من payload الحالي مع تحديث `reservation_orders` عند الحفظ.
- توسيع `ReservationServiceSummary` وطبقة الـRepository لقراءة payload الخاص بخدمات `Agent Direct` و`Transportation` وتحويله إلى Domain details قابلة لإعادة الاستخدام في الشاشات.
- تحسين عناوين الخدمات في `ReservationListScreen` و`ReservationDetailsScreen` لتعرض أسماء أوضح مثل `General service - Visit` واسم الفندق/المسار الفعلي بدل العناوين العامة.
- تحديث `ReservationDetailsScreen` لعرض بيانات حقيقية لخدمات `Agent Direct` و`Transportation` بدل القيم الثابتة، بما يشمل التواريخ، الليالي، RN، المورد، المسار، الشروط، الملاحظات، وتعاصيل الرحلات.
- تحديث شاشة `ReservationListScreen` لعرض تفاصيل الخدمات داخل الحجز في مجموعتين رئيسيتين: `Hotel direct` وحدها، و`Services` التي تجمع `General services` مع `Transportation`.
- تخصيص أعمدة مجموعة الفنادق لتبقى بصيغة `Hotel/Provider/Arrival/Departure/Rooms/RN`، مع استخدام أعمدة موحدة `Provider/Qty/Desc` داخل مجموعة الخدمات والمواصلات.
- إضافة صف إجمالي مستقل لكل مجموعة وصف `Grand total` نهائي داخل الجزء القابل للتمدد، مع الحفاظ على فتح شاشة التعديل الصحيحة لكل خدمة.
- تثبيت قياسات جداول قائمة الحجوزات لمنع مشاكل الـlayout مع بقاء `Expand All` و`Collapse All` تعملان على جميع الحجوزات.

### 2026-03-17
- تأكيد جداول Supabase الحالية في schema `public`: `clients`, `hotels`, `reservation_orders`, `reservation_service_types`, `reservation_services`, `suppliers`.
- اعتماد جدول `reservation_service_types` كمصدر لقائمة الخدمات/الأنواع (الأعمدة: `key`, `label`, `code`) بدل جدول غير موجود (`general_services`).
- تحديث تدفق `CreateGeneralServiceScreen` لقراءة عناصر حقل Service من `reservation_service_types` وعرض `label`، مع استبعاد `agent` و`transportation`، وربط الاختيار بالحفظ داخل `GeneralServiceDraft.serviceName`.
- تحديث شاشة `ReservationDetailsScreen` لتقارب التصميم المرجعي: Toolbar + Card واحدة تتضمن Header/Main info/Details/Totals مع نفس كثافة التصميم.
- إصلاح زر `Apply` في `Room details`: تعطيله في وضع `Manual rate`، وضمان تحديث قيم الصفوف عند التطبيق عن طريق إعادة تهيئة الحقول المعطلة عند تغيّر القيمة.
- حذف الحقول غير المطلوبة من صفحة `CreateAgentReservationScreen`: `Room No.`, `Hotel Conf. No.`, `Voucher`, `Reference No.`, `Detail remarks`, `Agreement No.`.

### 2026-03-15
- تحديث شاشة `CreateTransportationServiceScreen`: حذف حقول الحجز/VAT غير المطلوبة وتفعيل حسابات Sale/Cost بشكل ديناميكي باستخدام `Decimal`.
- اعتماد أزرار الحفظ باللون الأخضر `#198754` عبر شاشات الإنشاء (توكن: `AppColors.actionGreen`).
- إضافة حقل وقت موحد `CustomTimePickerField` وتحديث رأس تقويم `CustomDatePickerField` لتوحيد الشكل.
- تصغير Typography الموحدة وتقليل خط الـ Sidebar وتنسيق الجداول لتطابق الصور.

### 2026-03-14
- توثيق Template موحد لإنشاء Data Layer كاملة (Models/DTO/DataSource/Repository/Providers) وتطبيقه كنمط إلزامي لأي Feature جديدة أو تكرار مشابه.
- توحيد مقاسات وتباعدات شاشة `CreateGeneralServiceScreen` لتطابق `CreateAgentReservationScreen` (page/card padding 16 + gaps موحدة) مع الحفاظ على responsive behavior.
- إضافة طبقة بيانات `reservations/data` الخاصة بإنشاء حجز الوكيل: Domain draft model + JSON DTO + Repository + RemoteDataSource.
- إضافة إعداد Supabase مركزي في `lib/core/supabase/supabase_client_provider.dart` مع تهيئة آمنة تعتمد على `--dart-define`.
- ربط `CreateAgentReservationNotifier` بعملية حفظ فعلية (`saveReservation`) عبر Repository مع حالات `isSaving`, `lastSaveError`, `lastSavedReservationId`.
- ربط أزرار الحفظ في `CreateAgentReservationScreen` بعملية الحفظ وإظهار رسائل نجاح/فشل للمستخدم.
- فصل منطق شاشة `CreateAgentReservationScreen` بالكامل إلى `lib/features/reservations/provider/create_agent_reservation_provider.dart` باستخدام Riverpod Notifier.
- تحويل الشاشة إلى `ConsumerStatefulWidget` وربط أحداث الواجهة مع provider بدل `setState` الخاص بمنطق الأعمال.
- نقل نماذج الحالة (`CreateAgentReservationState`, `RoomDayRate`, `AddedRoomSummary`) إلى طبقة `provider` مع حالة immutable.
- إضافة/تحديث اختبار Widget لتأكيد تدفق زر `Add` بعد إعادة الهيكلة المعمارية.

### 2026-03-12
- إعداد Feature-first structure وإعادة تنظيم الملفات (core/features).
- إضافة GoRouter + Riverpod كأساس للتطبيق.
- تجهيز Shell layout ثابت (Sidebar/Header) عبر ShellRoute.
- تفعيل themeProvider و localeProvider وتحديث main.dart للعمل بـ MaterialApp.router.
- تعديل مسار البداية في الراوتر إلى `/reservations/create-agent` وإضافة redirects للمسارات المختصرة.
- تحديث صفحة `CreateAgentReservationScreen` لحذف الحقول غير الضرورية (Nationality, Balance, Tags, Remarks, etc.).
- تبسيط صفحة `CreateAgentReservationScreen` بشكل أكبر (إزالة Terms, Manual Rate, Adults/Children counts, Voucher, References).
- إزالة أقسام (Extra Details, Payment, Attachments) وتغيير `Room No.` إلى `Pax No.` في `CreateAgentReservationScreen`.
- ضبط قسم `Room details` في `CreateAgentReservationScreen` ليطابق التصميم الأصلي بدقة (إزالة `Prices do not include VAT`، تصغير المسافات والخطوط، وضبط شبكة Sale والأزرار).
- إعادة بناء `Room details` في `CreateAgentReservationScreen` طبقًا لـ HTML الأصلي حرفيًا (إظهار `Is manual rate` و`Prices do not include VAT`، إضافة Sale/Cost Grid كاملة، وتحديث صفوف الأيام وملخص الجدول).
- تحسين التطابق البصري لقسم `Room details` بنسبة أعلى عبر تنفيذ حقول الإدخال والاختيار العلوية بمقاسات ثابتة (ارتفاع 32، خط 12/11، وحواف `#E4E6EF`) لتطابق لقطة النظام الأصلي.
- إضافة `CustomDatePickerField` كـ widget عامة في `core/widgets` بنفس نمط الـHTML الأصلي (overlay calendar, month/year selectors, Monday-first grid) وتطبيقها على حقول التاريخ في شاشتي `CreateAgentReservationScreen` و`CreateGeneralServiceScreen`.
- تقليل أبعاد `CustomDatePickerField` والـoverlay calendar (عرض popup ثابت أصغر، ارتفاع الحقل، مقاسات الخطوط والخلايا) مع تصغير paddings في `CreateAgentReservationScreen` للحصول على نفس scale النظام الأصلي.
- تنفيذ تصغير إضافي قوي للـDate Picker ليطابق نسخة HTML المدمجة (عرض 300، خلايا أيام وحروف أصغر، رؤوس شهر/سنة dense، وحقول تاريخ بارتفاع 34) مع تطبيق القيم على الشاشات المرتبطة.
- ضبط تخطيط `Reservation details` في `CreateAgentReservationScreen` بعروض حقول ثابتة على الشاشات الواسعة لمطابقة الصورة المرجعية: `Arrival/Departure` أعرض، `Nights` أضيق، وتحديد عرضي `Client` و`Hotel` مع ترك مساحة بيضاء يمينًا بنفس نمط النظام الأصلي.
- إضافة تفاعل `hover` داخل تقويم `CustomDatePickerField` لتغيير خلفية ولون نص خلية اليوم عند مرور المؤشر بما يطابق سلوك التصميم المرجعي على الويب.
- تحويل `CustomDropdown` إلى widget عامة قابلة للبحث عبر Overlay مع قائمة نتائج مدمجة بنفس النمط المضغوط (ارتفاع حقل 34، خط صغير، قائمة قابلة للتمرير، وحالة `No results found`) لتُستخدم موحّدًا عبر التطبيق.
- تحديث ترتيب وعروض حقول `Reservation details` في `CreateAgentReservationScreen`: نقل `Client option date` لمكان `Hotel` بنفس العرض، ونقل `Hotel` لصف مستقل، وتثبيت عرض `Supplier` ليطابق عرض `Hotel` على الشاشات الواسعة.
- تنفيذ منطق ديناميكي في `CreateAgentReservationScreen` لربط `Arrival date` و`Departure date` بحساب `Nights` وتوليد صفوف `Room details` تلقائيًا بعدد الليالي.
- تفعيل منطق `Is manual rate` داخل `Room details`: عند التفعيل تصبح حقول `Room` و`Meal Per PAX` قابلة للإدخال لكل يوم، وعند الإلغاء يتم إدخال القيم من صف الإدخال العلوي وتطبيقها على كل الأيام عبر زر `Apply`.
- تفعيل إدخال `Nights` يدويًا في `Reservation details` مع تحديث `Departure date` تلقائيًا بناءً على عدد الليالي، ثم إعادة مزامنة صفوف `Room details` مباشرة.
- معالجة مشكلة فقدان التركيز أثناء الإدخال اليدوي داخل صفوف الأيام في `Room details` ليصبح الإدخال متصلًا وطبيعيًا بدون خروج من الحقل بعد كل حرف.
- تفعيل حقول الصف العلوي في `Room details` (`No. of rooms`, `Room type`, `Meal plan`) كحقول إدخال/اختيار فعلية بدل عناصر عرض فقط.
- تفعيل زر `Add` في `Room details` لإضافة الغرفة إلى جدول الملخص السفلي مع إنشاء صف فعلي لكل غرفة مضافة وإمكانية حذف الصف.
- إضافة حساب `PAX` تلقائيًا عند الإضافة اعتمادًا على `No. of rooms` و`Room type` (Single/Double/Twin/Triple/Family) وتحديث حقول `No. of adults` و`PAX` السفلية من إجمالي الغرف المضافة.
- تطبيق حسابات `Total Sale` و`Total Cost` في جدول الملخص باستخدام `decimal` بدل `double` لضمان دقة مالية أعلى.
