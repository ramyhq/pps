// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get cancel => 'إلغاء';

  @override
  String get keepPrices => 'احتفظ بالأسعار';

  @override
  String get resetPrices => 'تأكيد وتصفير';

  @override
  String get changeDatesTitle => 'تغيير التاريخ';

  @override
  String get changeDatesMessage => 'تغيير تاريخ الوصول/المغادرة أو عدد الليالي قد يصفّر أسعار الغرف، وستحتاج لإدخال الأسعار من جديد.';

  @override
  String get errorRoomPricesReset => 'تم تصفير أسعار الغرف بسبب تغيير التاريخ/عدد الليالي. من فضلك أدخل الأسعار من جديد.';

  @override
  String get errorRoomPricesZero => 'أسعار الغرف = 0. لا يمكن الحفظ قبل إدخال الأسعار.';

  @override
  String get printTotalsHintTooltip => 'جدول الغرف في الـ PDF هدفه يوضح توزيع السكن والإضافات (بشكل محاسبي)، لكنه مش دايمًا أفضل مصدر لحساب إجمالي الفاتورة بدقة 100% لأن:\n- التقريب على مستوى كل صف.\n- دمج/فصل الصفوف حسب المدينة والفترات.\n- في خدمات مش غرف (General/Transportation) لكنها داخلة في الإجمالي النهائي.';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get detailsTitle => 'التفاصيل';

  @override
  String get reservationsTitle => 'الحجوزات';

  @override
  String get rmsBridgeTitle => 'RMS Bridge';

  @override
  String get clientsTitle => 'العملاء';

  @override
  String get suppliersTitle => 'الموردون';

  @override
  String get hotelsTitle => 'الفنادق';

  @override
  String get servicesCatalogTitle => 'كتالوج الخدمات';

  @override
  String get templatesTitle => 'القوالب';

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sidebarSearchHint => 'بحث…';

  @override
  String get sidebarNoResults => 'لا توجد نتائج';

  @override
  String get sidebarSectionOperations => 'العمليات';

  @override
  String get sidebarSectionMasterData => 'البيانات الأساسية';

  @override
  String get sidebarSectionReports => 'التقارير';

  @override
  String get sidebarSectionIntegrations => 'التكاملات';

  @override
  String get sidebarSectionSettings => 'الإعدادات';

  @override
  String get sidebarSectionResults => 'النتائج';

  @override
  String get favorites => 'المفضلة';

  @override
  String get ppsResNumber => 'رقم حجز PPS';

  @override
  String get addAgentDirect => 'إضافة حجز Agent Direct';

  @override
  String get addGeneral => 'إضافة خدمة عامة';

  @override
  String get addTransport => 'إضافة نقل';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get loginTitle => 'تسجيل دخول RMS';

  @override
  String get loginUsernameHint => 'اسم المستخدم أو البريد';

  @override
  String get loginPasswordHint => 'كلمة المرور';

  @override
  String get loginRememberMe => 'تذكرني';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get rmsBridgeLogoutButton => 'تسجيل خروج RMS';

  @override
  String get rmsBridgeOpenDashboardButton => 'فتح RMS Bridge';

  @override
  String get rmsBridgeOpenRmsLoginButton => 'فتح تسجيل دخول RMS';

  @override
  String get loginInvalidCredentials => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get back => 'رجوع';

  @override
  String get close => 'إغلاق';

  @override
  String get save => 'حفظ';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get ok => 'موافق';

  @override
  String get print => 'طباعة';

  @override
  String get print1Summary => 'طباعة 1 — بسيط';

  @override
  String get print2Summary => 'طباعة 2 — مفصل (Mix)';

  @override
  String get partyPaxManual => 'عدد الأفراد (يدوي)';

  @override
  String get partyPaxManualHint => 'اختياري. بيستخدم لمراجعة سيجمنتات الفنادق وتوزيع الإضافات.';

  @override
  String get partyPaxManualIndicatorTooltip => 'لو فيه سيجمنتات PAX مختلفة عن عدد الأفراد (يدوي) هيظهر تحذير.';

  @override
  String get warningIndicatorDefaultTooltip => 'تحذير: راجع التفاصيل.';

  @override
  String get partyPaxMismatchTitle => 'اختلاف عدد الأفراد';

  @override
  String get partyPaxMismatchBodyPrefix => 'في سيجمنتات فنادق فيها PAX مختلف عن عدد الأفراد (يدوي):';

  @override
  String get fixNow => 'إصلاح الآن';

  @override
  String generalQtyMismatchTemplate(String qty, String manualPax) {
    return 'تحذير: كمية الخدمة العامة ($qty) مختلفة عن عدد الأفراد (يدوي) ($manualPax). لو Qty المقصود بيه عدد الأشخاص للخدمة دي، راجعها.';
  }

  @override
  String locationPaxMismatchTemplate(String place, String locationPax, String manualPax) {
    return 'تحذير: إجمالي PAX في $place ($locationPax) مختلف عن عدد الأفراد (يدوي) ($manualPax).';
  }

  @override
  String locationPaxDifferenceTemplate(String place, String placePax, String otherPlace, String otherPax) {
    return 'تحذير: إجمالي PAX في $place ($placePax) مختلف عن $otherPlace ($otherPax).';
  }

  @override
  String get print1SimpleBlockedTitle => 'طباعة 1 — بسيط غير متاحة';

  @override
  String get print1SimpleBlockedBodyIntro => 'لا يمكن استخدام طباعة 1 — بسيط لأن توزيع الغرف مختلف بين المدينة ومكة.\n\nالشرط لاستخدام طباعة 1:\n- مجموع Qty لكل نوع غرفة في MED لازم يساوي مجموع Qty لنفس النوع في MAK.\n\nمثال سريع:\n- Quad: MED=25 و MAK=25 → ينفع طباعة 1.\n- Quad: MED=25 و MAK=20 → لازم طباعة 2.\n\nالاختلافات الحالية:\n';

  @override
  String get print1SimpleBlockedUsePrint2Hint => 'استخدم طباعة 2 — مفصل (Mix) في الحالة دي.';

  @override
  String get printUsageBody => 'هشرح لك الموضوع كأنك أول مرة تستخدم النظام (بالعربي البسيط):\n\n1) يعني إيه (Qty / Nights / PAX)؟\n- Qty: عدد الغرف.\n- Nights: عدد الليالي.\n- PAX: عدد الأشخاص اللي الحساب بيتوزع عليهم.\n\n2) أهم قاعدة في الفاتورة\n- إجمالي الفاتورة (Total) = مجموع Total sale لكل الخدمات في الحجز.\n- جدول الغرف في الـ PDF وظيفته يشرح التوزيع، لكن رقم Total النهائي لازم يطابق الفاتورة.\n\n3) Party Pax (Manual) ده إيه؟\n- رقم اختياري إنت بتكتبه بنفسك.\n- المقصود منه: عدد المسافرين الحقيقي.\n- لو كتبته: بيتستخدم لتوزيع الإضافات (Add-ons) فقط.\n- لو ما كتبتهوش: النظام بيستخدم Qty Pax (محسوبة من توزيع الغرف) علشان يوزع الإضافات.\n\n4) النقطة الحمرا جنب Party Pax (Manual) معناها إيه؟\n- معناها إن فيه اختلاف بين PAX بتاع سيجمنت/فندق وبين Party Pax (Manual).\n- لازم تراجع الأرقام لأن ده بيأثر على توزيع الإضافات.\n\n5) إمتى أستخدم Print 1 (Simple)؟\n- لما يكون توزيع الغرف ثابت بين المدينة ومكة.\n- شرط أساسي: مجموع Qty لكل نوع غرفة في MED لازم يساوي مجموع Qty لنفس النوع في MAK.\n\n6) إمتى أستخدم Print 2 (Mix detailed)؟\n- لما توزيع الغرف مختلف بين المدينة ومكة (أو بين الفترات).\n- أو لما عايز تفاصيل أكتر عن تقسيم السكن حسب المدينة والفترات.\n\nملحوظة:\n- لو Print 1 مش متاح، النظام هيمنعك ويقولك ليه ويقترح Print 2.\n';

  @override
  String get calculationsGuideBody => 'طباعة 1 — بسيط:\n- Qty (المعروض) = أكبر عدد غرف في اليوم بعد دمج سيجمنتات الفندق.\n- PAX# = Qty × عدد الأشخاص/غرفة (Double=2, Triple=3, Quad=4, Quint=5).\n- الإضافات/فرد = (إجمالي بيع General + Transportation) / عدد الأفراد.\n- عدد الأفراد = عدد الأفراد (يدوي) لو مكتوب، وإلا بيتحسب من الغرف.\n\nطباعة 2 — مفصل (Mix):\n- لو توزيع الفندق مختلف حسب المدينة/الفترة، الصفوف بتتفصل حسب (المدينة + الفترة).\n- لو نوع الغرفة نفس الـ Qty عبر الفترات يفضل صف واحد.\n- الإضافات بتتوزع على الليالي لتجنب التكرار بين المدن.\n- إجمالي الـ PDF النهائي = إجمالي الفاتورة (مجموع services.totalSale).\n\nعدد الأفراد (يدوي):\n- رقم اختياري بتمثّل به عدد المسافرين الحقيقي.\n- لو أي سيجمنت فندق PAX مختلف، هيظهر تحذير أحمر.';

  @override
  String get mealPlan => 'نظام الوجبات';

  @override
  String get noOfRooms => 'عدد الغرف';

  @override
  String get pdfPreview => 'معاينة PDF';

  @override
  String get reservationMainInfoTitle => 'معلومات الحجز الأساسية';

  @override
  String get reservationDetailsTitle => 'تفاصيل الحجز';

  @override
  String get ppsResNumberLabel => 'رقم حجز PPS:';

  @override
  String get client => 'العميل';

  @override
  String get fromDate => 'من تاريخ';

  @override
  String get toDate => 'إلى تاريخ';

  @override
  String get guestName => 'اسم النزيل';

  @override
  String get clientOptionDate => 'تاريخ خيار العميل';

  @override
  String get rmsInvoiceNo => 'رقم فاتورة RMS';

  @override
  String get hotel => 'فندق';

  @override
  String get hotels => 'الفنادق';

  @override
  String get services => 'الخدمات';

  @override
  String get transportation => 'النقل';

  @override
  String get totalSale => 'إجمالي البيع';

  @override
  String get totalCost => 'إجمالي التكلفة';

  @override
  String get total => 'الإجمالي';

  @override
  String get creatorLabel => 'المنشئ:';

  @override
  String get dateLabel => 'التاريخ:';

  @override
  String get actions => 'إجراءات';

  @override
  String get more => 'المزيد';

  @override
  String get vehicleProvider => 'مزود النقل';

  @override
  String get serviceRoute => 'مسار الخدمة';

  @override
  String get arrivalDate => 'تاريخ الوصول';

  @override
  String get departureDate => 'تاريخ المغادرة';

  @override
  String get nights => 'ليالي';

  @override
  String get totalRn => 'إجمالي RN';

  @override
  String get pax => 'عدد الأشخاص';

  @override
  String get supplier => 'المورد';

  @override
  String get location => 'المدينة';

  @override
  String get madinah => 'المدينة';

  @override
  String get makkah => 'مكة';

  @override
  String get med => 'MED';

  @override
  String get mak => 'MAK';

  @override
  String get serviceName => 'اسم الخدمة';

  @override
  String get quantity => 'الكمية';

  @override
  String get salePrice => 'سعر البيع';

  @override
  String get costPrice => 'سعر التكلفة';

  @override
  String get dateOfService => 'تاريخ الخدمة';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get tripNotes => 'ملاحظات الرحلة';

  @override
  String get tripsDetails => 'تفاصيل الرحلات';

  @override
  String get transactionsNotes => 'ملاحظات المعاملات';

  @override
  String get serviceDescription => 'وصف الخدمة';

  @override
  String get roomType => 'نوع الغرفة';

  @override
  String get roomRate => 'سعر الغرفة';

  @override
  String get qty => 'العدد';

  @override
  String get providerOptionDate => 'تاريخ خيار المزود';

  @override
  String get providerRemarks => 'ملاحظات المزود';

  @override
  String get continueWithout => 'استمرار بدون';

  @override
  String get saveAndPrint => 'حفظ وطباعة';

  @override
  String get rmsInvoiceDialogTitle => 'رقم فاتورة RMS';

  @override
  String get rmsInvoiceDialogHint => 'اكتب رقم فاتورة RMS عشان يظهر في الـ PDF (اختياري).';

  @override
  String get rmsInvoiceMissingColumn => 'عمود RMS invoice غير موجود في قاعدة البيانات (reservation_orders).';

  @override
  String get rmsInvoiceIndicatorTooltip => 'RMS invoice no. محفوظ في قاعدة البيانات وبيظهر في الـ PDF.';

  @override
  String get missingReservationId => 'reservationId مفقود';

  @override
  String get addMoreForYourReservation => 'أضف المزيد لحجزك';

  @override
  String get agentDirectReservation => 'حجز Agent Direct';

  @override
  String get transportationService => 'خدمة نقل';

  @override
  String get generalService => 'خدمة عامة';

  @override
  String get calculationsGuide => 'دليل الحسابات';

  @override
  String get printUsageTitle => 'طريقة الطباعة';

  @override
  String get continueAnyway => 'استمرار';

  @override
  String get editInfoTitle => 'تعديل البيانات';

  @override
  String get editInfoTooltip => 'تعديل';

  @override
  String get deleteReservationTitle => 'حذف';

  @override
  String get deleteReservationMessage => 'حذف هذا الحجز؟';

  @override
  String get deleteServiceMessage => 'حذف هذه الخدمة؟';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get termsAndConditionsStandard => 'قياسي';

  @override
  String get termsAndConditionsTrain => 'قطار';

  @override
  String get dashboardSubtitle => 'نظرة عامة على الحجوزات والأداء.';

  @override
  String get dashboardSelectPeriodTooltip => 'اختر الفترة الزمنية لإحصائيات لوحة التحكم.';

  @override
  String dashboardErrorLoading(String error) {
    return 'حصل خطأ أثناء تحميل لوحة التحكم: $error';
  }

  @override
  String dashboardLastDays(int days) {
    return 'آخر $days يوم';
  }

  @override
  String dashboardLastDaysShort(int days) {
    return 'آخر $days يوم';
  }

  @override
  String get dashboardTodaysReservationsTitle => 'حجوزات اليوم';

  @override
  String get dashboardTodaysReservationsTooltip => 'عدد الحجوزات التي تم إنشاؤها اليوم.';

  @override
  String get dashboardThisWeekTitle => 'هذا الأسبوع';

  @override
  String get dashboardThisWeekTooltip => 'عدد الحجوزات التي تم إنشاؤها هذا الأسبوع.';

  @override
  String dashboardPeriodTotalTitle(int days) {
    return 'إجمالي الفترة ($days يوم)';
  }

  @override
  String get dashboardPeriodTotalTooltip => 'إجمالي الحجوزات التي تم إنشاؤها داخل الفترة المحددة.';

  @override
  String get dashboardNeedsAttentionTitle => 'بحاجة لمتابعة';

  @override
  String get dashboardNeedsAttentionTooltip => 'حجوزات تحتاج رقم فاتورة RMS داخل فترة المتابعة.';

  @override
  String get dashboardReservationsOverviewTitle => 'نظرة عامة على الحجوزات';

  @override
  String get dashboardReservationsOverviewTooltip => 'يعرض اتجاه يومي للحجوزات خلال الفترة المحددة.';

  @override
  String get dashboardDailyVolumeSubtitle => 'حجم الحجوزات اليومية التي تم إنشاؤها.';

  @override
  String dashboardReservationsCount(int count) {
    return '$count حجز';
  }

  @override
  String get dashboardNeedsAttentionListTooltip => 'قائمة بآخر الحجوزات التي مازال ينقصها رقم فاتورة RMS.';

  @override
  String get dashboardFollowUpPeriodTooltip => 'اختر عدد الأيام السابقة لفحص الحجوزات بدون رقم فاتورة RMS.';

  @override
  String get dashboardNeedsAttentionSubtitle => 'آخر حجوزات ينقصها رقم فاتورة RMS.';

  @override
  String get dashboardAllCaughtUp => 'كل شيء تمام!';

  @override
  String dashboardPpsNumber(int reservationNo) {
    return 'PPS: #$reservationNo';
  }

  @override
  String dashboardRmsInvoice(String value) {
    return 'RMS: $value';
  }

  @override
  String get dashboardTopClientsTitle => 'أفضل العملاء';

  @override
  String get dashboardTopClientsTooltip => 'يعرض أفضل 5 عملاء حسب عدد الحجوزات خلال الفترة المحددة.';

  @override
  String get dashboardTopClientsSubtitle => 'العملاء الأكثر من حيث عدد الحجوزات خلال الفترة المحددة.';

  @override
  String get dashboardRankFirstTooltip => 'المركز الأول - كأس ذهبي';

  @override
  String get dashboardRankSecondTooltip => 'المركز الثاني - كأس فضي';

  @override
  String get dashboardRankThirdTooltip => 'المركز الثالث - ميدالية ذهبية';

  @override
  String get dashboardRankFourthTooltip => 'المركز الرابع - ميدالية فضية';

  @override
  String dashboardReservationsAbbrev(int count) {
    return '$count حجز';
  }

  @override
  String get search => 'بحث';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get exportToExcel => 'تصدير إلى Excel';

  @override
  String get exportToPdf => 'تصدير إلى PDF';

  @override
  String get createReservation => 'إنشاء حجز';

  @override
  String get create => 'إنشاء';

  @override
  String get reservationFiltersInfoGroup => 'بيانات الحجز';

  @override
  String get reservationFiltersDatesGroup => 'تواريخ الحجز';

  @override
  String get reservationFiltersGuestNationality => 'جنسية النزيل';

  @override
  String get reservationFiltersClientNationality => 'جنسية العميل';

  @override
  String get reservationFiltersHotelCity => 'مدينة الفندق';

  @override
  String get reservationFiltersHotelCategory => 'تصنيف الفندق';

  @override
  String get reservationFiltersSaleAllotment => 'حصة البيع';

  @override
  String get reservationFiltersArrivalDateRange => 'نطاق تاريخ الوصول';

  @override
  String get reservationFiltersDepartureDateRange => 'نطاق تاريخ المغادرة';

  @override
  String get reservationFiltersCreationDateRange => 'نطاق تاريخ الإنشاء';

  @override
  String get reservationFiltersClientOptionDateRange => 'نطاق تاريخ خيار العميل';

  @override
  String get reservationFiltersHotelOptionDateRange => 'نطاق تاريخ خيار الفندق';

  @override
  String get reservationFiltersAgentOptionDateRange => 'نطاق تاريخ خيار الوكيل';

  @override
  String get reservationFiltersServiceDateRange => 'نطاق تاريخ الخدمة';

  @override
  String get reservationFiltersIncludeServices => 'تضمين الخدمات';

  @override
  String get reservationFiltersTypesGroup => 'الأنواع والحالة';

  @override
  String get reservationFiltersReservationType => 'نوع الحجز';

  @override
  String get reservationFiltersServiceType => 'نوع الخدمة';

  @override
  String get reservationFiltersMyReservations => 'حجوزاتي';

  @override
  String get reservationFiltersType => 'النوع';

  @override
  String get reservationFiltersIsSent => 'تم الإرسال';

  @override
  String get status => 'الحالة';

  @override
  String get reservationFiltersFinancialStatus => 'الحالة المالية';

  @override
  String get reservationFiltersPaymentStatus => 'حالة الدفع';

  @override
  String get reservationFiltersInvoiced => 'تمت الفوترة';

  @override
  String get reservationFiltersSplitReservation => 'تقسيم الحجز';

  @override
  String get reservationFiltersExtraGroup => 'تفاصيل إضافية';

  @override
  String get reservationFiltersConfirmation => 'تأكيد';

  @override
  String get reservationFiltersVoucher => 'قسيمة';

  @override
  String get reservationFiltersFileNo => 'رقم الملف';

  @override
  String get reservationFiltersReferenceNo => 'الرقم المرجعي';

  @override
  String get reservationFiltersAgreementNo => 'رقم الاتفاقية';

  @override
  String get reservationFiltersEnteredBy => 'أُدخل بواسطة';

  @override
  String get reservationFiltersB2bStatus => 'حالة B2B';

  @override
  String get company => 'الشركة';

  @override
  String get reservationFiltersSubClient => 'عميل فرعي';

  @override
  String get reservationFiltersSalesperson => 'مندوب المبيعات';

  @override
  String get creator => 'المنشئ';

  @override
  String get tag => 'وسم';

  @override
  String get reservationFiltersOrderBy => 'ترتيب حسب';

  @override
  String get reservationFiltersDirection => 'الاتجاه';

  @override
  String get reservationFiltersRemarksGroup => 'ملاحظات';

  @override
  String get reservationFiltersReservationRemarks => 'ملاحظات الحجز';

  @override
  String get reservationFiltersDetailRemarks => 'ملاحظات التفاصيل';

  @override
  String get reservationFiltersClientRemarks => 'ملاحظات العميل';

  @override
  String get reservationFiltersHotelRemarks => 'ملاحظات الفندق';

  @override
  String get reservationFiltersAgentRemarks => 'ملاحظات الوكيل';

  @override
  String get fromToHint => 'من - إلى';

  @override
  String get all => 'الكل';

  @override
  String get expandAll => 'توسيع الكل';

  @override
  String get collapseAll => 'طيّ الكل';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get loadingServices => 'جارٍ تحميل الخدمات...';

  @override
  String get noReservationsFound => 'لا توجد حجوزات.';

  @override
  String get noServicesFoundForReservation => 'لا توجد خدمات لهذا الحجز.';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get tags => 'وسوم';

  @override
  String get sale => 'البيع';

  @override
  String get paid => 'المدفوع';

  @override
  String get remaining => 'المتبقي';

  @override
  String get show => 'عرض';

  @override
  String get entries => 'سجلات';

  @override
  String showingEntriesRange(int from, int to, int total) {
    return 'عرض $from إلى $to من $total سجل';
  }

  @override
  String get rooms => 'غرف';

  @override
  String get rn => 'RN';

  @override
  String get cost => 'التكلفة';

  @override
  String get provider => 'المزوّد';

  @override
  String get date => 'التاريخ';

  @override
  String get desc => 'الوصف';

  @override
  String get service => 'الخدمة';

  @override
  String get qtyShort => 'الكمية';

  @override
  String get grandTotal => 'الإجمالي الكلي';

  @override
  String get view => 'عرض';

  @override
  String get unpost => 'إلغاء ترحيل';

  @override
  String get sendEmail => 'إرسال بريد';

  @override
  String get transactionsDetails => 'تفاصيل المعاملات';

  @override
  String get auditLog => 'سجل التدقيق';

  @override
  String get agentDirect => 'حجز مباشر';

  @override
  String get hotelDirect => 'مباشر';

  @override
  String tripWithNumber(String no) {
    return 'رحلة $no';
  }

  @override
  String serviceWithNumber(String no) {
    return 'خدمة $no';
  }

  @override
  String generalServiceWithName(String name) {
    return 'خدمة عامة - $name';
  }

  @override
  String get providerFallback => 'المزوّد';

  @override
  String get notEnoughData => 'لا توجد بيانات كافية.';
}
