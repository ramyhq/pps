class AppStrings {
  static const dashboardTitle = 'Dashboard';
  static const detailsTitle = 'Details';
  static const reservationsTitle = 'Reservations';
  static const rmsBridgeTitle = 'RMS Bridge';
  static const clientsTitle = 'Clients';
  static const suppliersTitle = 'Suppliers';
  static const hotelsTitle = 'Hotels';
  static const servicesCatalogTitle = 'Services Catalog';
  static const templatesTitle = 'Templates';
  static const reportsTitle = 'Reports';
  static const settingsTitle = 'Settings';

  static const sidebarSearchHint = 'Search…';
  static const sidebarNoResults = 'No results';
  static const sidebarSectionOperations = 'Operations';
  static const sidebarSectionMasterData = 'Master Data';
  static const sidebarSectionReports = 'Reports';
  static const sidebarSectionIntegrations = 'Integrations';
  static const sidebarSectionSettings = 'Settings';
  static const sidebarSectionResults = 'Results';
  static const back = 'Back';
  static const missingReservationId = 'Missing reservationId';

  static const rmsBridgeSubtitle = 'Bridge RMS reservations into PPS workflow.';
  static const rmsBridgeImportReservationTitle = 'Import Reservation';
  static const rmsBridgeImportReservationSubtitle =
      'Extract reservation preview from RMS.';
  static const rmsBridgeRmsLoginTitle = 'RMS Login';
  static const rmsBridgeRmsLoginSubtitle = 'Create/refresh RMS session.';
  static const rmsBridgeImportReservationHint =
      'Enter reservationId, then preview hotels, totals, dates, and clientId.';
  static const rmsBridgeReservationDetailsTitle = 'RMS Reservation Details';

  static const rmsBridgeReservationIdInputLabel = 'Reservation ID';
  static const rmsBridgeReservationIdInputHint = 'e.g. 1364033';
  static const rmsBridgeImportButton = 'Import';
  static const rmsBridgeOpenRmsLoginButton = 'Open RMS Login';
  static const rmsBridgeMissingSessionHint =
      'RMS session is missing. Open RMS Login first.';

  static const rmsBridgeReservationIdLabel = 'Reservation ID:';
  static const rmsBridgeReservationNoLabel = 'Reservation No:';
  static const rmsBridgeClientIdLabel = 'Client ID:';
  static const rmsBridgeOpenDetailsButton = 'Open details';
  static const rmsBridgeHotelsPreviewTitle = 'Hotels';
  static const rmsBridgeNoHotelsFound = 'No hotels found in this reservation.';
  static const rmsBridgeUnnamedHotel = 'Hotel';

  static const reservationMainInfoTitle = 'Reservation main info';
  static const reservationDetailsTitle = 'Reservation details';
  static const client = 'Client';
  static const fromDate = 'From date';
  static const toDate = 'To date';
  static const guestName = 'Guest name';
  static const clientOptionDate = 'Client option date';

  static const editInfoTitle = 'Edit Info';
  static const editInfoTooltip = 'Edit info';
  static const edit = 'Edit';
  static const close = 'Close';
  static const save = 'Save';
  static const saved = 'Saved';

  static const clientPaymentDetailsTitle = 'Client payment details';
  static const createClientPayment = 'Create Client Payment';
  static const viewBalance = 'View Balance';
  static const totalSale = 'Total sale';
  static const totalCost = 'Total cost';
  static const addMoreForYourReservation = 'Add more for your reservation';
  static const hotels = 'Hotels';
  static const services = 'Services';
  static const agentDirectReservation = 'Agent direct reservation';
  static const transportation = 'Transportation';

  static const reservationIdLabel = 'Res. ID:';
  static const creatorLabel = 'Creator:';
  static const dateLabel = 'Date:';

  static const actions = 'Actions';
  static const addAgentDirect = 'Add Agent Direct';
  static const addGeneral = 'Add General';
  static const addTransport = 'Add Transport';
  static const print = 'Print';
  static const pdfPreview = 'PDF Preview';
  static const attachments = 'Attachments';
  static const delete = 'Delete';
  static const deleteReservationTitle = 'Delete';
  static const deleteReservationMessage = 'Delete this reservation?';
  static const deleteServiceMessage = 'Delete this service?';
  static const cancel = 'Cancel';
  static const deleted = 'Deleted';

  static const vehicleProvider = 'Vehicle provider';
  static const serviceRoute = 'Service route';
  static const arrivalDate = 'Arrival date';
  static const departureDate = 'Departure date';
  static const nights = 'Nights';
  static const totalRn = 'Total RN';
  static const pax = 'PAX';
  static const supplier = 'Supplier';
  static const hotel = 'Hotel';
  static const serviceName = 'Service name';
  static const quantity = 'Quantity';
  static const salePrice = 'Sale price';
  static const costPrice = 'Cost price';
  static const dateOfService = 'Date of service';
  static const endDate = 'End date';
  static const termsAndConditions = 'Terms & conditions';
  static const termsAndConditionsDefaultKey = 'Standard';
  static const termsAndConditionsOptions = <String>[
    termsAndConditionsDefaultKey,
    'Train',
  ];
  static const termsAndConditionsTemplates = <String, String>{
    'Standard':
        'Above Rates are net & non commision-able quoted in Saudi Riyals.\n'
        'Above rates includes 15% Vat + 5% municipality.\n'
        'Check in after 16:00 hours and check out at 12:00 hour.\n'
        'Check in or check out amendment for individuals should be done 72 hours prior to guest check in.\n'
        'Check in or check out amendment for Group should be 7 days prior to guest check in.\n'
        'In case of no-show for groups full amount will be charged.\n'
        'In case of no-show for individuals first night will be charged.\n'
        'Right after confirmation, booking amendments, shouldn\'t exceed 20% of total confirmed rooms.\n'
        'Triple and Quad occupancy will be provided with extra bed, If standard room is not available.\n'
        'PAYMENT POLICY:\n'
        'Groups booking payment will be as follows:\n'
        '• %25 of total amount upon confirmation.\n'
        '• %25 of total amount has to be paid 21 days before each group arrival.\n'
        '• %50 of total amount has to be paid 14 days before each group arrival.\n'
        '• booking amendments, shouldn\'t exceed 20% of total confirmed rooms.',
    'Train': '-',
  };
  static const providerOptionDate = 'Provider option date';
  static const transactionsNotes = 'Transactions notes';
  static const providerRemarks = 'Provider remarks';
  static const serviceDescription = 'Service description';
  static const tripsDetails = 'Trips details';
  static const tripNotes = 'Trip notes';
  static const roomType = 'Room type';
  static const mealPlan = 'Meal plan';
  static const noOfRooms = 'No. of rooms';
  static const roomRate = 'Room rate';
  static const total = 'Total';
  static const quadCv = 'Quad CV';
  static const ro = 'R.O';
  static const qty = 'Qty';

  static const agentDirect = 'Agent Direct';
  static const generalService = 'General service';
  static const transportationService = 'Transportation service';
  static const generalServicePrefix = 'General service - ';
  static const transportationPrefix = 'Transportation - ';

  static const placeholderHeading = 'Coming soon';
  static const placeholderHint =
      'This page is a placeholder until the full implementation is completed.';

  static const dashboardPlaceholderDescription =
      'Quick overview: today/week reservations, total sales/cost, and latest orders.';
  static const dashboardKpiToday = 'Today';
  static const dashboardKpiThisWeek = 'This week';
  static const dashboardKpiSalesCost = 'Sales / Cost';
  static const dashboardKpiReservations = 'Reservations';
  static const dashboardKpiTotals = 'Totals';
  static const dashboardLatestOrders = 'Latest orders';
  static const clientsPlaceholderDescription =
      'Clients list and client details. Bulk import will be added later.';
  static const suppliersPlaceholderDescription =
      'Suppliers list and supplier details. Bulk import will be added later.';
  static const hotelsPlaceholderDescription =
      'Hotels list and hotel details. Bulk import will be added later.';
  static const servicesCatalogPlaceholderDescription =
      'Services catalog powered by Supabase tables (service types, labels, codes).';
  static const templatesPlaceholderDescription =
      'Terms & conditions templates available in the app today.';
  static const reportsPlaceholderDescription =
      'Sales/cost/margin insights and printable summaries.';
  static const settingsPlaceholderDescription =
      'Users/Roles, app settings, and integrations will be added later.';

  static const loginTitle = 'Log in';
  static const loginUsernameHint = 'User name or email';
  static const loginPasswordHint = 'Password';
  static const loginRememberMe = 'Remember me';
  static const loginForgotPassword = 'Forgot password?';
  static const loginButton = 'Log in';
}
