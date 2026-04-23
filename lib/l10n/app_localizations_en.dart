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

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get detailsTitle => 'Details';

  @override
  String get reservationsTitle => 'Reservations';

  @override
  String get rmsBridgeTitle => 'RMS Bridge';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get suppliersTitle => 'Suppliers';

  @override
  String get hotelsTitle => 'Hotels';

  @override
  String get servicesCatalogTitle => 'Services Catalog';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sidebarSearchHint => 'Search…';

  @override
  String get sidebarNoResults => 'No results';

  @override
  String get sidebarSectionOperations => 'Operations';

  @override
  String get sidebarSectionMasterData => 'Master Data';

  @override
  String get sidebarSectionReports => 'Reports';

  @override
  String get sidebarSectionIntegrations => 'Integrations';

  @override
  String get sidebarSectionSettings => 'Settings';

  @override
  String get sidebarSectionResults => 'Results';

  @override
  String get favorites => 'Favorites';

  @override
  String get ppsResNumber => 'PPS Res Number';

  @override
  String get addAgentDirect => 'Add Agent Direct';

  @override
  String get addGeneral => 'Add General';

  @override
  String get addTransport => 'Add Transport';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get loginTitle => 'RMS Login';

  @override
  String get loginUsernameHint => 'Username or email';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get rmsBridgeLogoutButton => 'Logout RMS';

  @override
  String get rmsBridgeOpenDashboardButton => 'Open RMS Bridge';

  @override
  String get rmsBridgeOpenRmsLoginButton => 'Open RMS Login';

  @override
  String get loginInvalidCredentials => 'Invalid username or password.';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get print => 'Print';

  @override
  String get print1Summary => 'Print 1 — Simple';

  @override
  String get print2Summary => 'Print 2 — Mix detailed';

  @override
  String get partyPaxManual => 'Party Pax (Manual)';

  @override
  String get partyPaxManualHint => 'Optional. Used to validate hotel segments and distribute add-ons.';

  @override
  String get partyPaxManualIndicatorTooltip => 'If any segments have PAX different from Party Pax (Manual), a warning will appear.';

  @override
  String get warningIndicatorDefaultTooltip => 'Warning: review details.';

  @override
  String get partyPaxMismatchTitle => 'Party Pax mismatch';

  @override
  String get partyPaxMismatchBodyPrefix => 'Some hotel segments have PAX different from Party Pax (Manual):';

  @override
  String get fixNow => 'Fix now';

  @override
  String generalQtyMismatchTemplate(String qty, String manualPax) {
    return 'Warning: General service Qty ($qty) differs from Party Pax (Manual) ($manualPax). If Qty represents PAX for this service, review it.';
  }

  @override
  String locationPaxMismatchTemplate(String place, String locationPax, String manualPax) {
    return 'Warning: Total PAX in $place ($locationPax) differs from Party Pax (Manual) ($manualPax).';
  }

  @override
  String locationPaxDifferenceTemplate(String place, String placePax, String otherPlace, String otherPax) {
    return 'Warning: Total PAX in $place ($placePax) differs from $otherPlace ($otherPax).';
  }

  @override
  String get print1SimpleBlockedTitle => 'Print 1 — Simple is not available';

  @override
  String get print1SimpleBlockedBodyIntro => 'Print 1 — Simple cannot be used because room distribution differs between MED and MAK.\n\nPrint 1 requires:\n- Total Qty for each room type in MED must equal total Qty for the same type in MAK.\n\nQuick example:\n- Quad: MED=25 and MAK=25 → Print 1 works.\n- Quad: MED=25 and MAK=20 → Print 2 is required.\n\nCurrent differences:\n';

  @override
  String get print1SimpleBlockedUsePrint2Hint => 'Use Print 2 — Mix detailed in this case.';

  @override
  String get printUsageBody => 'شرح استخدام Print 1 (Simple) و Print 2 (Mix detailed)\n\nSwitch to Arabic to read the full guide.';

  @override
  String get calculationsGuideBody => 'Print 1 — Simple:\n- Qty (display) = Max rooms per day after merging hotel segments.\n- PAX# = Qty × Pax/Room (Double=2, Triple=3, Quad=4, Quint=5).\n- Add-ons / Pax = (Total Sale of General + Transportation) / Party Pax.\n- Party Pax = Party Pax (Manual) if entered, otherwise Qty Pax derived from rooms.\n\nPrint 2 — Mix detailed:\n- If hotel distribution differs by city/date segment, rows split by (city + date range).\n- If a room type keeps the same Qty across segments, it stays as a single row.\n- Add-ons are distributed by nights to avoid double counting across cities.\n- Final PDF Total equals the invoice total (sum of services.totalSale).\n\nParty Pax (Manual):\n- Optional number you enter to represent the real travelers count.\n- If any hotel segment has different PAX, the system shows a red warning dot.';

  @override
  String get mealPlan => 'Meal plan';

  @override
  String get noOfRooms => 'No. of rooms';

  @override
  String get pdfPreview => 'PDF Preview';

  @override
  String get reservationMainInfoTitle => 'Reservation main info';

  @override
  String get reservationDetailsTitle => 'Reservation details';

  @override
  String get ppsResNumberLabel => 'PPS Res Number:';

  @override
  String get client => 'Client';

  @override
  String get fromDate => 'From date';

  @override
  String get toDate => 'To date';

  @override
  String get guestName => 'Guest name';

  @override
  String get clientOptionDate => 'Client option date';

  @override
  String get rmsInvoiceNo => 'RMS invoice no.';

  @override
  String get hotel => 'Hotel';

  @override
  String get hotels => 'Hotels';

  @override
  String get services => 'Services';

  @override
  String get transportation => 'Transportation';

  @override
  String get totalSale => 'Total sale';

  @override
  String get totalCost => 'Total cost';

  @override
  String get total => 'Total';

  @override
  String get creatorLabel => 'Creator:';

  @override
  String get dateLabel => 'Date:';

  @override
  String get actions => 'Actions';

  @override
  String get more => 'More';

  @override
  String get vehicleProvider => 'Vehicle provider';

  @override
  String get serviceRoute => 'Service route';

  @override
  String get arrivalDate => 'Arrival date';

  @override
  String get departureDate => 'Departure date';

  @override
  String get nights => 'Nights';

  @override
  String get totalRn => 'Total RN';

  @override
  String get pax => 'PAX';

  @override
  String get supplier => 'Supplier';

  @override
  String get location => 'Location';

  @override
  String get madinah => 'Madinah';

  @override
  String get makkah => 'Makkah';

  @override
  String get med => 'MED';

  @override
  String get mak => 'MAK';

  @override
  String get serviceName => 'Service name';

  @override
  String get quantity => 'Quantity';

  @override
  String get salePrice => 'Sale price';

  @override
  String get costPrice => 'Cost price';

  @override
  String get dateOfService => 'Date of service';

  @override
  String get endDate => 'End date';

  @override
  String get termsAndConditions => 'Terms & conditions';

  @override
  String get tripNotes => 'Trip notes';

  @override
  String get tripsDetails => 'Trips details';

  @override
  String get transactionsNotes => 'Transactions notes';

  @override
  String get serviceDescription => 'Service description';

  @override
  String get roomType => 'Room type';

  @override
  String get roomRate => 'Room rate';

  @override
  String get qty => 'Qty';

  @override
  String get providerOptionDate => 'Provider option date';

  @override
  String get providerRemarks => 'Provider remarks';

  @override
  String get continueWithout => 'Continue without';

  @override
  String get saveAndPrint => 'Save & Print';

  @override
  String get rmsInvoiceDialogTitle => 'RMS invoice number';

  @override
  String get rmsInvoiceDialogHint => 'Enter RMS invoice number to show it on the PDF (optional).';

  @override
  String get rmsInvoiceMissingColumn => 'Missing reservation_orders RMS invoice column in database.';

  @override
  String get rmsInvoiceIndicatorTooltip => 'RMS invoice no. محفوظ في قاعدة البيانات وبيظهر في الـ PDF.';

  @override
  String get missingReservationId => 'Missing reservationId';

  @override
  String get addMoreForYourReservation => 'Add more for your reservation';

  @override
  String get agentDirectReservation => 'Agent direct reservation';

  @override
  String get transportationService => 'Transportation service';

  @override
  String get generalService => 'General service';

  @override
  String get calculationsGuide => 'Calculations guide';

  @override
  String get printUsageTitle => 'Print usage';

  @override
  String get continueAnyway => 'Continue anyway';

  @override
  String get editInfoTitle => 'Edit info';

  @override
  String get editInfoTooltip => 'Edit';

  @override
  String get deleteReservationTitle => 'Delete';

  @override
  String get deleteReservationMessage => 'Delete this reservation?';

  @override
  String get deleteServiceMessage => 'Delete this service?';

  @override
  String get deleted => 'Deleted';

  @override
  String get termsAndConditionsStandard => 'Standard';

  @override
  String get termsAndConditionsTrain => 'Train';

  @override
  String get dashboardSubtitle => 'Overview of your reservations and performance.';

  @override
  String get dashboardSelectPeriodTooltip => 'Select the time period for dashboard statistics.';

  @override
  String dashboardErrorLoading(String error) {
    return 'Error loading dashboard: $error';
  }

  @override
  String dashboardLastDays(int days) {
    return 'Last $days days';
  }

  @override
  String dashboardLastDaysShort(int days) {
    return 'Last $days Days';
  }

  @override
  String get dashboardTodaysReservationsTitle => 'Today\'s Reservations';

  @override
  String get dashboardTodaysReservationsTooltip => 'Number of reservations created today.';

  @override
  String get dashboardThisWeekTitle => 'This Week';

  @override
  String get dashboardThisWeekTooltip => 'Number of reservations created this week.';

  @override
  String dashboardPeriodTotalTitle(int days) {
    return 'Period Total ($days Days)';
  }

  @override
  String get dashboardPeriodTotalTooltip => 'Total reservations created within the selected period.';

  @override
  String get dashboardNeedsAttentionTitle => 'Needs Attention';

  @override
  String get dashboardNeedsAttentionTooltip => 'Reservations needing RMS Invoice within the follow-up period.';

  @override
  String get dashboardReservationsOverviewTitle => 'Reservations Overview';

  @override
  String get dashboardReservationsOverviewTooltip => 'Shows a visual trend of daily reservations over the selected period.';

  @override
  String get dashboardDailyVolumeSubtitle => 'Daily volume of reservations created.';

  @override
  String dashboardReservationsCount(int count) {
    return '$count Reservations';
  }

  @override
  String get dashboardNeedsAttentionListTooltip => 'List of recent reservations that still need an RMS invoice number.';

  @override
  String get dashboardFollowUpPeriodTooltip => 'Select how many days back to check for missing RMS invoices.';

  @override
  String get dashboardNeedsAttentionSubtitle => 'Recent reservations missing RMS Invoice.';

  @override
  String get dashboardAllCaughtUp => 'All caught up!';

  @override
  String dashboardPpsNumber(int reservationNo) {
    return 'PPS: #$reservationNo';
  }

  @override
  String dashboardRmsInvoice(String value) {
    return 'RMS: $value';
  }

  @override
  String get dashboardTopClientsTitle => 'Top Clients';

  @override
  String get dashboardTopClientsTooltip => 'Shows the top 5 clients based on the number of reservations created in the selected period.';

  @override
  String get dashboardTopClientsSubtitle => 'Clients with the highest volume of reservations in the selected period.';

  @override
  String get dashboardRankFirstTooltip => '1st Place - Gold Cup';

  @override
  String get dashboardRankSecondTooltip => '2nd Place - Silver Cup';

  @override
  String get dashboardRankThirdTooltip => '3rd Place - Gold Medal';

  @override
  String get dashboardRankFourthTooltip => '4th Place - Silver Medal';

  @override
  String dashboardReservationsAbbrev(int count) {
    return '$count Res.';
  }

  @override
  String get search => 'Search';

  @override
  String get reset => 'Reset';

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get exportToPdf => 'Export to PDF';

  @override
  String get createReservation => 'Create reservation';

  @override
  String get create => 'Create';

  @override
  String get reservationFiltersInfoGroup => 'Reservation info';

  @override
  String get reservationFiltersDatesGroup => 'Reservation dates';

  @override
  String get reservationFiltersGuestNationality => 'Guest nationality';

  @override
  String get reservationFiltersClientNationality => 'Client nationality';

  @override
  String get reservationFiltersHotelCity => 'Hotel city';

  @override
  String get reservationFiltersHotelCategory => 'Hotel category';

  @override
  String get reservationFiltersSaleAllotment => 'Sale allotment';

  @override
  String get reservationFiltersArrivalDateRange => 'Arrival date range';

  @override
  String get reservationFiltersDepartureDateRange => 'Departure date range';

  @override
  String get reservationFiltersCreationDateRange => 'Creation date range';

  @override
  String get reservationFiltersClientOptionDateRange => 'Client option date range';

  @override
  String get reservationFiltersHotelOptionDateRange => 'Hotel option date range';

  @override
  String get reservationFiltersAgentOptionDateRange => 'Agent option date range';

  @override
  String get reservationFiltersServiceDateRange => 'Service date range';

  @override
  String get reservationFiltersIncludeServices => 'Include services';

  @override
  String get reservationFiltersTypesGroup => 'Types & status';

  @override
  String get reservationFiltersReservationType => 'Reservation type';

  @override
  String get reservationFiltersServiceType => 'Service type';

  @override
  String get reservationFiltersMyReservations => 'My reservations';

  @override
  String get reservationFiltersType => 'Type';

  @override
  String get reservationFiltersIsSent => 'Is sent';

  @override
  String get status => 'Status';

  @override
  String get reservationFiltersFinancialStatus => 'Financial status';

  @override
  String get reservationFiltersPaymentStatus => 'Payment status';

  @override
  String get reservationFiltersInvoiced => 'Invoiced';

  @override
  String get reservationFiltersSplitReservation => 'Split reservation';

  @override
  String get reservationFiltersExtraGroup => 'Extra details';

  @override
  String get reservationFiltersConfirmation => 'Conf.';

  @override
  String get reservationFiltersVoucher => 'Voucher';

  @override
  String get reservationFiltersFileNo => 'File No.';

  @override
  String get reservationFiltersReferenceNo => 'Reference No.';

  @override
  String get reservationFiltersAgreementNo => 'Agreement No.';

  @override
  String get reservationFiltersEnteredBy => 'Entered by';

  @override
  String get reservationFiltersB2bStatus => 'B2B status';

  @override
  String get company => 'Company';

  @override
  String get reservationFiltersSubClient => 'Sub client';

  @override
  String get reservationFiltersSalesperson => 'Salesperson';

  @override
  String get creator => 'Creator';

  @override
  String get tag => 'Tag';

  @override
  String get reservationFiltersOrderBy => 'Order by';

  @override
  String get reservationFiltersDirection => 'Direction';

  @override
  String get reservationFiltersRemarksGroup => 'Remarks';

  @override
  String get reservationFiltersReservationRemarks => 'Reservation remarks';

  @override
  String get reservationFiltersDetailRemarks => 'Detail remarks';

  @override
  String get reservationFiltersClientRemarks => 'Client remarks';

  @override
  String get reservationFiltersHotelRemarks => 'Hotel remarks';

  @override
  String get reservationFiltersAgentRemarks => 'Agent remarks';

  @override
  String get fromToHint => 'From - To';

  @override
  String get all => 'All';

  @override
  String get expandAll => 'Expand all';

  @override
  String get collapseAll => 'Collapse all';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingServices => 'Loading services...';

  @override
  String get noReservationsFound => 'No reservations found.';

  @override
  String get noServicesFoundForReservation => 'No services found for this reservation.';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get tags => 'Tags';

  @override
  String get sale => 'Sale';

  @override
  String get paid => 'Paid';

  @override
  String get remaining => 'Remaining';

  @override
  String get show => 'Show';

  @override
  String get entries => 'entries';

  @override
  String showingEntriesRange(int from, int to, int total) {
    return 'Showing $from to $to of $total entries';
  }

  @override
  String get rooms => 'Rooms';

  @override
  String get rn => 'RN';

  @override
  String get cost => 'Cost';

  @override
  String get provider => 'Provider';

  @override
  String get date => 'Date';

  @override
  String get desc => 'Desc';

  @override
  String get service => 'Service';

  @override
  String get qtyShort => 'Qty';

  @override
  String get grandTotal => 'Grand total';

  @override
  String get view => 'View';

  @override
  String get unpost => 'Unpost';

  @override
  String get sendEmail => 'Send email';

  @override
  String get transactionsDetails => 'Transactions details';

  @override
  String get auditLog => 'Audit log';

  @override
  String get agentDirect => 'Agent Direct';

  @override
  String get hotelDirect => 'Hotel Direct';

  @override
  String tripWithNumber(String no) {
    return 'Trip $no';
  }

  @override
  String serviceWithNumber(String no) {
    return 'Service $no';
  }

  @override
  String generalServiceWithName(String name) {
    return 'General service - $name';
  }

  @override
  String get providerFallback => 'Provider';

  @override
  String get notEnoughData => 'Not enough data.';
}
