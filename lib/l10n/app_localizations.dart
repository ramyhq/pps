import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @keepPrices.
  ///
  /// In en, this message translates to:
  /// **'Keep prices'**
  String get keepPrices;

  /// No description provided for @resetPrices.
  ///
  /// In en, this message translates to:
  /// **'Confirm & reset'**
  String get resetPrices;

  /// No description provided for @changeDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Change dates'**
  String get changeDatesTitle;

  /// No description provided for @changeDatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Changing arrival/departure dates or nights can reset room prices and you will need to re-enter them.'**
  String get changeDatesMessage;

  /// No description provided for @errorRoomPricesReset.
  ///
  /// In en, this message translates to:
  /// **'Room prices were reset due to date/nights change. Please re-enter prices.'**
  String get errorRoomPricesReset;

  /// No description provided for @errorRoomPricesZero.
  ///
  /// In en, this message translates to:
  /// **'Room prices are 0. Please enter prices before saving.'**
  String get errorRoomPricesZero;

  /// No description provided for @printTotalsHintTooltip.
  ///
  /// In en, this message translates to:
  /// **'The PDF room table is meant to explain accommodation and add-ons distribution (accounting-friendly), but it may not be the best source for a 100% exact invoice total because:\n- Row-level rounding.\n- Row merge/split by city and date ranges.\n- Some services are not rooms (General/Transportation) but are included in the final total.'**
  String get printTotalsHintTooltip;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTitle;

  /// No description provided for @reservationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservationsTitle;

  /// No description provided for @rmsBridgeTitle.
  ///
  /// In en, this message translates to:
  /// **'RMS Bridge'**
  String get rmsBridgeTitle;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @suppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersTitle;

  /// No description provided for @hotelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotelsTitle;

  /// No description provided for @servicesCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Services Catalog'**
  String get servicesCatalogTitle;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTitle;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sidebarSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get sidebarSearchHint;

  /// No description provided for @sidebarNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get sidebarNoResults;

  /// No description provided for @sidebarSectionOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get sidebarSectionOperations;

  /// No description provided for @sidebarSectionMasterData.
  ///
  /// In en, this message translates to:
  /// **'Master Data'**
  String get sidebarSectionMasterData;

  /// No description provided for @sidebarSectionReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get sidebarSectionReports;

  /// No description provided for @sidebarSectionIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get sidebarSectionIntegrations;

  /// No description provided for @sidebarSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sidebarSectionSettings;

  /// No description provided for @sidebarSectionResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get sidebarSectionResults;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @ppsResNumber.
  ///
  /// In en, this message translates to:
  /// **'PPS Res Number'**
  String get ppsResNumber;

  /// No description provided for @addAgentDirect.
  ///
  /// In en, this message translates to:
  /// **'Add Agent Direct'**
  String get addAgentDirect;

  /// No description provided for @addGeneral.
  ///
  /// In en, this message translates to:
  /// **'Add General'**
  String get addGeneral;

  /// No description provided for @addTransport.
  ///
  /// In en, this message translates to:
  /// **'Add Transport'**
  String get addTransport;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'RMS Login'**
  String get loginTitle;

  /// No description provided for @loginUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get loginUsernameHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordHint;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get loginRememberMe;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @rmsBridgeLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout RMS'**
  String get rmsBridgeLogoutButton;

  /// No description provided for @rmsBridgeOpenDashboardButton.
  ///
  /// In en, this message translates to:
  /// **'Open RMS Bridge'**
  String get rmsBridgeOpenDashboardButton;

  /// No description provided for @rmsBridgeOpenRmsLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Open RMS Login'**
  String get rmsBridgeOpenRmsLoginButton;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get loginInvalidCredentials;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @pdfPreview.
  ///
  /// In en, this message translates to:
  /// **'PDF Preview'**
  String get pdfPreview;

  /// No description provided for @reservationMainInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation main info'**
  String get reservationMainInfoTitle;

  /// No description provided for @reservationDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation details'**
  String get reservationDetailsTitle;

  /// No description provided for @ppsResNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'PPS Res Number:'**
  String get ppsResNumberLabel;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest name'**
  String get guestName;

  /// No description provided for @clientOptionDate.
  ///
  /// In en, this message translates to:
  /// **'Client option date'**
  String get clientOptionDate;

  /// No description provided for @rmsInvoiceNo.
  ///
  /// In en, this message translates to:
  /// **'RMS invoice no.'**
  String get rmsInvoiceNo;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @totalSale.
  ///
  /// In en, this message translates to:
  /// **'Total sale'**
  String get totalSale;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get totalCost;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @creatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Creator:'**
  String get creatorLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get dateLabel;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @vehicleProvider.
  ///
  /// In en, this message translates to:
  /// **'Vehicle provider'**
  String get vehicleProvider;

  /// No description provided for @serviceRoute.
  ///
  /// In en, this message translates to:
  /// **'Service route'**
  String get serviceRoute;

  /// No description provided for @arrivalDate.
  ///
  /// In en, this message translates to:
  /// **'Arrival date'**
  String get arrivalDate;

  /// No description provided for @departureDate.
  ///
  /// In en, this message translates to:
  /// **'Departure date'**
  String get departureDate;

  /// No description provided for @nights.
  ///
  /// In en, this message translates to:
  /// **'Nights'**
  String get nights;

  /// No description provided for @totalRn.
  ///
  /// In en, this message translates to:
  /// **'Total RN'**
  String get totalRn;

  /// No description provided for @pax.
  ///
  /// In en, this message translates to:
  /// **'PAX'**
  String get pax;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @madinah.
  ///
  /// In en, this message translates to:
  /// **'Madinah'**
  String get madinah;

  /// No description provided for @makkah.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get makkah;

  /// No description provided for @med.
  ///
  /// In en, this message translates to:
  /// **'MED'**
  String get med;

  /// No description provided for @mak.
  ///
  /// In en, this message translates to:
  /// **'MAK'**
  String get mak;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service name'**
  String get serviceName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get salePrice;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get costPrice;

  /// No description provided for @dateOfService.
  ///
  /// In en, this message translates to:
  /// **'Date of service'**
  String get dateOfService;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get termsAndConditions;

  /// No description provided for @tripNotes.
  ///
  /// In en, this message translates to:
  /// **'Trip notes'**
  String get tripNotes;

  /// No description provided for @tripsDetails.
  ///
  /// In en, this message translates to:
  /// **'Trips details'**
  String get tripsDetails;

  /// No description provided for @transactionsNotes.
  ///
  /// In en, this message translates to:
  /// **'Transactions notes'**
  String get transactionsNotes;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service description'**
  String get serviceDescription;

  /// No description provided for @roomType.
  ///
  /// In en, this message translates to:
  /// **'Room type'**
  String get roomType;

  /// No description provided for @roomRate.
  ///
  /// In en, this message translates to:
  /// **'Room rate'**
  String get roomRate;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @providerOptionDate.
  ///
  /// In en, this message translates to:
  /// **'Provider option date'**
  String get providerOptionDate;

  /// No description provided for @providerRemarks.
  ///
  /// In en, this message translates to:
  /// **'Provider remarks'**
  String get providerRemarks;

  /// No description provided for @continueWithout.
  ///
  /// In en, this message translates to:
  /// **'Continue without'**
  String get continueWithout;

  /// No description provided for @saveAndPrint.
  ///
  /// In en, this message translates to:
  /// **'Save & Print'**
  String get saveAndPrint;

  /// No description provided for @rmsInvoiceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'RMS invoice number'**
  String get rmsInvoiceDialogTitle;

  /// No description provided for @rmsInvoiceDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter RMS invoice number to show it on the PDF (optional).'**
  String get rmsInvoiceDialogHint;

  /// No description provided for @rmsInvoiceMissingColumn.
  ///
  /// In en, this message translates to:
  /// **'Missing reservation_orders RMS invoice column in database.'**
  String get rmsInvoiceMissingColumn;

  /// No description provided for @rmsInvoiceIndicatorTooltip.
  ///
  /// In en, this message translates to:
  /// **'RMS invoice no. محفوظ في قاعدة البيانات وبيظهر في الـ PDF.'**
  String get rmsInvoiceIndicatorTooltip;

  /// No description provided for @missingReservationId.
  ///
  /// In en, this message translates to:
  /// **'Missing reservationId'**
  String get missingReservationId;

  /// No description provided for @addMoreForYourReservation.
  ///
  /// In en, this message translates to:
  /// **'Add more for your reservation'**
  String get addMoreForYourReservation;

  /// No description provided for @agentDirectReservation.
  ///
  /// In en, this message translates to:
  /// **'Agent direct reservation'**
  String get agentDirectReservation;

  /// No description provided for @transportationService.
  ///
  /// In en, this message translates to:
  /// **'Transportation service'**
  String get transportationService;

  /// No description provided for @generalService.
  ///
  /// In en, this message translates to:
  /// **'General service'**
  String get generalService;

  /// No description provided for @calculationsGuide.
  ///
  /// In en, this message translates to:
  /// **'Calculations guide'**
  String get calculationsGuide;

  /// No description provided for @printUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Print usage'**
  String get printUsageTitle;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @editInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit info'**
  String get editInfoTitle;

  /// No description provided for @editInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editInfoTooltip;

  /// No description provided for @deleteReservationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteReservationTitle;

  /// No description provided for @deleteReservationMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this reservation?'**
  String get deleteReservationMessage;

  /// No description provided for @deleteServiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this service?'**
  String get deleteServiceMessage;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @termsAndConditionsStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get termsAndConditionsStandard;

  /// No description provided for @termsAndConditionsTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get termsAndConditionsTrain;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
