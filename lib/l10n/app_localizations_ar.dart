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
  String get termsAndConditionsStandard => 'Standard';

  @override
  String get termsAndConditionsTrain => 'Train';
}
