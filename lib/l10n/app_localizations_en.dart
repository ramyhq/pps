// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get keepPrices => 'Keep prices';

  @override
  String get resetPrices => 'Confirm & reset';

  @override
  String get changeDatesTitle => 'Change dates';

  @override
  String get changeDatesMessage => 'Changing arrival/departure dates or nights can reset room prices and you will need to re-enter them.';

  @override
  String get errorRoomPricesReset => 'Room prices were reset due to date/nights change. Please re-enter prices.';

  @override
  String get errorRoomPricesZero => 'Room prices are 0. Please enter prices before saving.';

  @override
  String get printTotalsHintTooltip => 'The PDF room table is meant to explain accommodation and add-ons distribution (accounting-friendly), but it may not be the best source for a 100% exact invoice total because:\n- Row-level rounding.\n- Row merge/split by city and date ranges.\n- Some services are not rooms (General/Transportation) but are included in the final total.';
}
