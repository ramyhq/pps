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
}
