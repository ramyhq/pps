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

  /// No description provided for @print1Summary.
  ///
  /// In en, this message translates to:
  /// **'Print 1 — Simple'**
  String get print1Summary;

  /// No description provided for @print2Summary.
  ///
  /// In en, this message translates to:
  /// **'Print 2 — Mix detailed'**
  String get print2Summary;

  /// No description provided for @partyPaxManual.
  ///
  /// In en, this message translates to:
  /// **'Party Pax (Manual)'**
  String get partyPaxManual;

  /// No description provided for @partyPaxManualHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Used to validate hotel segments and distribute add-ons.'**
  String get partyPaxManualHint;

  /// No description provided for @partyPaxManualIndicatorTooltip.
  ///
  /// In en, this message translates to:
  /// **'If any segments have PAX different from Party Pax (Manual), a warning will appear.'**
  String get partyPaxManualIndicatorTooltip;

  /// No description provided for @warningIndicatorDefaultTooltip.
  ///
  /// In en, this message translates to:
  /// **'Warning: review details.'**
  String get warningIndicatorDefaultTooltip;

  /// No description provided for @partyPaxMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Party Pax mismatch'**
  String get partyPaxMismatchTitle;

  /// No description provided for @partyPaxMismatchBodyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Some hotel segments have PAX different from Party Pax (Manual):'**
  String get partyPaxMismatchBodyPrefix;

  /// No description provided for @fixNow.
  ///
  /// In en, this message translates to:
  /// **'Fix now'**
  String get fixNow;

  /// No description provided for @generalQtyMismatchTemplate.
  ///
  /// In en, this message translates to:
  /// **'Warning: General service Qty ({qty}) differs from Party Pax (Manual) ({manualPax}). If Qty represents PAX for this service, review it.'**
  String generalQtyMismatchTemplate(String qty, String manualPax);

  /// No description provided for @locationPaxMismatchTemplate.
  ///
  /// In en, this message translates to:
  /// **'Warning: Total PAX in {place} ({locationPax}) differs from Party Pax (Manual) ({manualPax}).'**
  String locationPaxMismatchTemplate(String place, String locationPax, String manualPax);

  /// No description provided for @locationPaxDifferenceTemplate.
  ///
  /// In en, this message translates to:
  /// **'Warning: Total PAX in {place} ({placePax}) differs from {otherPlace} ({otherPax}).'**
  String locationPaxDifferenceTemplate(String place, String placePax, String otherPlace, String otherPax);

  /// No description provided for @print1SimpleBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Print 1 — Simple is not available'**
  String get print1SimpleBlockedTitle;

  /// No description provided for @print1SimpleBlockedBodyIntro.
  ///
  /// In en, this message translates to:
  /// **'Print 1 — Simple cannot be used because room distribution differs between MED and MAK.\n\nPrint 1 requires:\n- Total Qty for each room type in MED must equal total Qty for the same type in MAK.\n\nQuick example:\n- Quad: MED=25 and MAK=25 → Print 1 works.\n- Quad: MED=25 and MAK=20 → Print 2 is required.\n\nCurrent differences:\n'**
  String get print1SimpleBlockedBodyIntro;

  /// No description provided for @print1SimpleBlockedUsePrint2Hint.
  ///
  /// In en, this message translates to:
  /// **'Use Print 2 — Mix detailed in this case.'**
  String get print1SimpleBlockedUsePrint2Hint;

  /// No description provided for @printUsageBody.
  ///
  /// In en, this message translates to:
  /// **'شرح استخدام Print 1 (Simple) و Print 2 (Mix detailed)\n\nSwitch to Arabic to read the full guide.'**
  String get printUsageBody;

  /// No description provided for @calculationsGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Print 1 — Simple:\n- Qty (display) = Max rooms per day after merging hotel segments.\n- PAX# = Qty × Pax/Room (Double=2, Triple=3, Quad=4, Quint=5).\n- Add-ons / Pax = (Total Sale of General + Transportation) / Party Pax.\n- Party Pax = Party Pax (Manual) if entered, otherwise Qty Pax derived from rooms.\n\nPrint 2 — Mix detailed:\n- If hotel distribution differs by city/date segment, rows split by (city + date range).\n- If a room type keeps the same Qty across segments, it stays as a single row.\n- Add-ons are distributed by nights to avoid double counting across cities.\n- Final PDF Total equals the invoice total (sum of services.totalSale).\n\nParty Pax (Manual):\n- Optional number you enter to represent the real travelers count.\n- If any hotel segment has different PAX, the system shows a red warning dot.'**
  String get calculationsGuideBody;

  /// No description provided for @mealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal plan'**
  String get mealPlan;

  /// No description provided for @noOfRooms.
  ///
  /// In en, this message translates to:
  /// **'No. of rooms'**
  String get noOfRooms;

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

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of your reservations and performance.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardSelectPeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select the time period for dashboard statistics.'**
  String get dashboardSelectPeriodTooltip;

  /// No description provided for @dashboardErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard: {error}'**
  String dashboardErrorLoading(String error);

  /// No description provided for @dashboardLastDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String dashboardLastDays(int days);

  /// No description provided for @dashboardLastDaysShort.
  ///
  /// In en, this message translates to:
  /// **'Last {days} Days'**
  String dashboardLastDaysShort(int days);

  /// No description provided for @dashboardTodaysReservationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reservations'**
  String get dashboardTodaysReservationsTitle;

  /// No description provided for @dashboardTodaysReservationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of reservations created today.'**
  String get dashboardTodaysReservationsTooltip;

  /// No description provided for @dashboardThisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get dashboardThisWeekTitle;

  /// No description provided for @dashboardThisWeekTooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of reservations created this week.'**
  String get dashboardThisWeekTooltip;

  /// No description provided for @dashboardPeriodTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Period Total ({days} Days)'**
  String dashboardPeriodTotalTitle(int days);

  /// No description provided for @dashboardPeriodTotalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Total reservations created within the selected period.'**
  String get dashboardPeriodTotalTooltip;

  /// No description provided for @dashboardNeedsAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get dashboardNeedsAttentionTitle;

  /// No description provided for @dashboardNeedsAttentionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reservations needing RMS Invoice within the follow-up period.'**
  String get dashboardNeedsAttentionTooltip;

  /// No description provided for @dashboardReservationsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservations Overview'**
  String get dashboardReservationsOverviewTitle;

  /// No description provided for @dashboardReservationsOverviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shows a visual trend of daily reservations over the selected period.'**
  String get dashboardReservationsOverviewTooltip;

  /// No description provided for @dashboardDailyVolumeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily volume of reservations created.'**
  String get dashboardDailyVolumeSubtitle;

  /// No description provided for @dashboardReservationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Reservations'**
  String dashboardReservationsCount(int count);

  /// No description provided for @dashboardNeedsAttentionListTooltip.
  ///
  /// In en, this message translates to:
  /// **'List of recent reservations that still need an RMS invoice number.'**
  String get dashboardNeedsAttentionListTooltip;

  /// No description provided for @dashboardFollowUpPeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select how many days back to check for missing RMS invoices.'**
  String get dashboardFollowUpPeriodTooltip;

  /// No description provided for @dashboardNeedsAttentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent reservations missing RMS Invoice.'**
  String get dashboardNeedsAttentionSubtitle;

  /// No description provided for @dashboardAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get dashboardAllCaughtUp;

  /// No description provided for @dashboardPpsNumber.
  ///
  /// In en, this message translates to:
  /// **'PPS: #{reservationNo}'**
  String dashboardPpsNumber(int reservationNo);

  /// No description provided for @dashboardRmsInvoice.
  ///
  /// In en, this message translates to:
  /// **'RMS: {value}'**
  String dashboardRmsInvoice(String value);

  /// No description provided for @dashboardTopClientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Clients'**
  String get dashboardTopClientsTitle;

  /// No description provided for @dashboardTopClientsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shows the top 5 clients based on the number of reservations created in the selected period.'**
  String get dashboardTopClientsTooltip;

  /// No description provided for @dashboardTopClientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clients with the highest volume of reservations in the selected period.'**
  String get dashboardTopClientsSubtitle;

  /// No description provided for @dashboardRankFirstTooltip.
  ///
  /// In en, this message translates to:
  /// **'1st Place - Gold Cup'**
  String get dashboardRankFirstTooltip;

  /// No description provided for @dashboardRankSecondTooltip.
  ///
  /// In en, this message translates to:
  /// **'2nd Place - Silver Cup'**
  String get dashboardRankSecondTooltip;

  /// No description provided for @dashboardRankThirdTooltip.
  ///
  /// In en, this message translates to:
  /// **'3rd Place - Gold Medal'**
  String get dashboardRankThirdTooltip;

  /// No description provided for @dashboardRankFourthTooltip.
  ///
  /// In en, this message translates to:
  /// **'4th Place - Silver Medal'**
  String get dashboardRankFourthTooltip;

  /// No description provided for @dashboardReservationsAbbrev.
  ///
  /// In en, this message translates to:
  /// **'{count} Res.'**
  String dashboardReservationsAbbrev(int count);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// No description provided for @exportToPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPdf;

  /// No description provided for @createReservation.
  ///
  /// In en, this message translates to:
  /// **'Create reservation'**
  String get createReservation;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @reservationFiltersInfoGroup.
  ///
  /// In en, this message translates to:
  /// **'Reservation info'**
  String get reservationFiltersInfoGroup;

  /// No description provided for @reservationFiltersDatesGroup.
  ///
  /// In en, this message translates to:
  /// **'Reservation dates'**
  String get reservationFiltersDatesGroup;

  /// No description provided for @reservationFiltersGuestNationality.
  ///
  /// In en, this message translates to:
  /// **'Guest nationality'**
  String get reservationFiltersGuestNationality;

  /// No description provided for @reservationFiltersClientNationality.
  ///
  /// In en, this message translates to:
  /// **'Client nationality'**
  String get reservationFiltersClientNationality;

  /// No description provided for @reservationFiltersHotelCity.
  ///
  /// In en, this message translates to:
  /// **'Hotel city'**
  String get reservationFiltersHotelCity;

  /// No description provided for @reservationFiltersHotelCategory.
  ///
  /// In en, this message translates to:
  /// **'Hotel category'**
  String get reservationFiltersHotelCategory;

  /// No description provided for @reservationFiltersSaleAllotment.
  ///
  /// In en, this message translates to:
  /// **'Sale allotment'**
  String get reservationFiltersSaleAllotment;

  /// No description provided for @reservationFiltersArrivalDateRange.
  ///
  /// In en, this message translates to:
  /// **'Arrival date range'**
  String get reservationFiltersArrivalDateRange;

  /// No description provided for @reservationFiltersDepartureDateRange.
  ///
  /// In en, this message translates to:
  /// **'Departure date range'**
  String get reservationFiltersDepartureDateRange;

  /// No description provided for @reservationFiltersCreationDateRange.
  ///
  /// In en, this message translates to:
  /// **'Creation date range'**
  String get reservationFiltersCreationDateRange;

  /// No description provided for @reservationFiltersClientOptionDateRange.
  ///
  /// In en, this message translates to:
  /// **'Client option date range'**
  String get reservationFiltersClientOptionDateRange;

  /// No description provided for @reservationFiltersHotelOptionDateRange.
  ///
  /// In en, this message translates to:
  /// **'Hotel option date range'**
  String get reservationFiltersHotelOptionDateRange;

  /// No description provided for @reservationFiltersAgentOptionDateRange.
  ///
  /// In en, this message translates to:
  /// **'Agent option date range'**
  String get reservationFiltersAgentOptionDateRange;

  /// No description provided for @reservationFiltersServiceDateRange.
  ///
  /// In en, this message translates to:
  /// **'Service date range'**
  String get reservationFiltersServiceDateRange;

  /// No description provided for @reservationFiltersIncludeServices.
  ///
  /// In en, this message translates to:
  /// **'Include services'**
  String get reservationFiltersIncludeServices;

  /// No description provided for @reservationFiltersTypesGroup.
  ///
  /// In en, this message translates to:
  /// **'Types & status'**
  String get reservationFiltersTypesGroup;

  /// No description provided for @reservationFiltersReservationType.
  ///
  /// In en, this message translates to:
  /// **'Reservation type'**
  String get reservationFiltersReservationType;

  /// No description provided for @reservationFiltersServiceType.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get reservationFiltersServiceType;

  /// No description provided for @reservationFiltersMyReservations.
  ///
  /// In en, this message translates to:
  /// **'My reservations'**
  String get reservationFiltersMyReservations;

  /// No description provided for @reservationFiltersType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reservationFiltersType;

  /// No description provided for @reservationFiltersIsSent.
  ///
  /// In en, this message translates to:
  /// **'Is sent'**
  String get reservationFiltersIsSent;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @reservationFiltersFinancialStatus.
  ///
  /// In en, this message translates to:
  /// **'Financial status'**
  String get reservationFiltersFinancialStatus;

  /// No description provided for @reservationFiltersPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get reservationFiltersPaymentStatus;

  /// No description provided for @reservationFiltersInvoiced.
  ///
  /// In en, this message translates to:
  /// **'Invoiced'**
  String get reservationFiltersInvoiced;

  /// No description provided for @reservationFiltersSplitReservation.
  ///
  /// In en, this message translates to:
  /// **'Split reservation'**
  String get reservationFiltersSplitReservation;

  /// No description provided for @reservationFiltersExtraGroup.
  ///
  /// In en, this message translates to:
  /// **'Extra details'**
  String get reservationFiltersExtraGroup;

  /// No description provided for @reservationFiltersConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Conf.'**
  String get reservationFiltersConfirmation;

  /// No description provided for @reservationFiltersVoucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get reservationFiltersVoucher;

  /// No description provided for @reservationFiltersFileNo.
  ///
  /// In en, this message translates to:
  /// **'File No.'**
  String get reservationFiltersFileNo;

  /// No description provided for @reservationFiltersReferenceNo.
  ///
  /// In en, this message translates to:
  /// **'Reference No.'**
  String get reservationFiltersReferenceNo;

  /// No description provided for @reservationFiltersAgreementNo.
  ///
  /// In en, this message translates to:
  /// **'Agreement No.'**
  String get reservationFiltersAgreementNo;

  /// No description provided for @reservationFiltersEnteredBy.
  ///
  /// In en, this message translates to:
  /// **'Entered by'**
  String get reservationFiltersEnteredBy;

  /// No description provided for @reservationFiltersB2bStatus.
  ///
  /// In en, this message translates to:
  /// **'B2B status'**
  String get reservationFiltersB2bStatus;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @reservationFiltersSubClient.
  ///
  /// In en, this message translates to:
  /// **'Sub client'**
  String get reservationFiltersSubClient;

  /// No description provided for @reservationFiltersSalesperson.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get reservationFiltersSalesperson;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @reservationFiltersOrderBy.
  ///
  /// In en, this message translates to:
  /// **'Order by'**
  String get reservationFiltersOrderBy;

  /// No description provided for @reservationFiltersDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get reservationFiltersDirection;

  /// No description provided for @reservationFiltersRemarksGroup.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get reservationFiltersRemarksGroup;

  /// No description provided for @reservationFiltersReservationRemarks.
  ///
  /// In en, this message translates to:
  /// **'Reservation remarks'**
  String get reservationFiltersReservationRemarks;

  /// No description provided for @reservationFiltersDetailRemarks.
  ///
  /// In en, this message translates to:
  /// **'Detail remarks'**
  String get reservationFiltersDetailRemarks;

  /// No description provided for @reservationFiltersClientRemarks.
  ///
  /// In en, this message translates to:
  /// **'Client remarks'**
  String get reservationFiltersClientRemarks;

  /// No description provided for @reservationFiltersHotelRemarks.
  ///
  /// In en, this message translates to:
  /// **'Hotel remarks'**
  String get reservationFiltersHotelRemarks;

  /// No description provided for @reservationFiltersAgentRemarks.
  ///
  /// In en, this message translates to:
  /// **'Agent remarks'**
  String get reservationFiltersAgentRemarks;

  /// No description provided for @fromToHint.
  ///
  /// In en, this message translates to:
  /// **'From - To'**
  String get fromToHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @expandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get expandAll;

  /// No description provided for @collapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get collapseAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingServices.
  ///
  /// In en, this message translates to:
  /// **'Loading services...'**
  String get loadingServices;

  /// No description provided for @noReservationsFound.
  ///
  /// In en, this message translates to:
  /// **'No reservations found.'**
  String get noReservationsFound;

  /// No description provided for @noServicesFoundForReservation.
  ///
  /// In en, this message translates to:
  /// **'No services found for this reservation.'**
  String get noServicesFoundForReservation;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'entries'**
  String get entries;

  /// No description provided for @showingEntriesRange.
  ///
  /// In en, this message translates to:
  /// **'Showing {from} to {to} of {total} entries'**
  String showingEntriesRange(int from, int to, int total);

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @rn.
  ///
  /// In en, this message translates to:
  /// **'RN'**
  String get rn;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @desc.
  ///
  /// In en, this message translates to:
  /// **'Desc'**
  String get desc;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @qtyShort.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qtyShort;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get grandTotal;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @unpost.
  ///
  /// In en, this message translates to:
  /// **'Unpost'**
  String get unpost;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// No description provided for @transactionsDetails.
  ///
  /// In en, this message translates to:
  /// **'Transactions details'**
  String get transactionsDetails;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @agentDirect.
  ///
  /// In en, this message translates to:
  /// **'Agent Direct'**
  String get agentDirect;

  /// No description provided for @hotelDirect.
  ///
  /// In en, this message translates to:
  /// **'Hotel Direct'**
  String get hotelDirect;

  /// No description provided for @tripWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Trip {no}'**
  String tripWithNumber(String no);

  /// No description provided for @serviceWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Service {no}'**
  String serviceWithNumber(String no);

  /// No description provided for @generalServiceWithName.
  ///
  /// In en, this message translates to:
  /// **'General service - {name}'**
  String generalServiceWithName(String name);

  /// No description provided for @providerFallback.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get providerFallback;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data.'**
  String get notEnoughData;
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
