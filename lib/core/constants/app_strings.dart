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
  static const loginInvalidCredentials = 'Invalid username or password.';

  static const rmsBridgeSubtitle = 'Bridge RMS reservations into PPS workflow.';
  static const rmsBridgeDashboardTitle = 'RMS Bridge Dashboard';
  static const rmsBridgeDashboardSubtitle =
      'Manage RMS sessions and import RMS data into PPS.';
  static const rmsBridgeSessionConnected = 'Session connected';
  static const rmsBridgeSessionDisconnected = 'Session disconnected';
  static const rmsBridgeSignedInAs = 'Signed in as';
  static const rmsBridgeLoginRequiredMessage =
      'Connect to RMS first to use RMS Bridge tools.';
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
  static const rmsBridgeOpenDashboardButton = 'Open RMS Bridge';
  static const rmsBridgeLogoutButton = 'Logout RMS';
  static const rmsBridgeMissingSessionHint =
      'RMS session is missing. Open RMS Login first.';

  static const rmsBridgeSyncClientsTitle = 'Sync Clients';
  static const rmsBridgeSyncClientsSubtitle = 'Pull clients from RMS into PPS.';
  static const rmsBridgeSyncSuppliersTitle = 'Sync Suppliers';
  static const rmsBridgeSyncSuppliersSubtitle =
      'Pull suppliers/vendors from RMS into PPS.';
  static const rmsBridgeSyncHotelsTitle = 'Sync Hotels';
  static const rmsBridgeSyncHotelsSubtitle = 'Pull hotels from RMS into PPS.';
  static const rmsBridgeSyncNationalitiesTitle = 'Sync Nationalities';
  static const rmsBridgeSyncNationalitiesSubtitle =
      'Pull nationalities list from RMS.';
  static const rmsBridgeSyncExtraServiceTypesTitle = 'Sync Extra Service Types';
  static const rmsBridgeSyncExtraServiceTypesSubtitle =
      'Pull extra service types from RMS.';
  static const rmsBridgeSyncRoutesTitle = 'Sync Routes';
  static const rmsBridgeSyncRoutesSubtitle = 'Pull routes list from RMS.';
  static const rmsBridgeSyncVehicleTypesTitle = 'Sync Vehicle Types';
  static const rmsBridgeSyncVehicleTypesSubtitle =
      'Pull vehicle types list from RMS.';
  static const rmsBridgeSyncTermsTitle = 'Sync Terms & Conditions';
  static const rmsBridgeSyncTermsSubtitle =
      'Pull terms & conditions list from RMS.';
  static const rmsBridgeSyncTripTypesTitle = 'Sync Trip Types';
  static const rmsBridgeExportExcel = 'Export Excel';
  static const rmsBridgeExportJson = 'Export JSON';
  static const rmsBridgeSupabaseSync = 'Supabase Sync';
  static const rmsBridgeRefresh = 'Refresh';
  static const rmsBridgeCopyError = 'Copy error';
  static const rmsBridgeCopiedToClipboard = 'Copied to clipboard';
  static const rmsBridgeSupabaseSyncDialogTitle = 'Supabase Sync';
  static const rmsBridgeModelClients = 'Clients';
  static const rmsBridgeModelSuppliers = 'Suppliers';
  static const rmsBridgeModelHotels = 'Hotels';
  static const rmsBridgeModelNationalities = 'Nationalities';
  static const rmsBridgeModelExtraServiceTypes = 'Extra Service Types';
  static const rmsBridgeModelRoutes = 'Routes';
  static const rmsBridgeModelVehicleTypes = 'Vehicle Types';
  static const rmsBridgeModelTermsAndConditions = 'Terms & Conditions';
  static const rmsBridgeModelTripTypes = 'Trip Types';
  static const rmsBridgeSupabaseModelLabel = 'Model';
  static const rmsBridgeSupabaseConnectionLabel = 'Supabase status';
  static const rmsBridgeSupabaseConfigured = 'Configured';
  static const rmsBridgeSupabaseNotConfigured = 'Not configured';
  static const rmsBridgeSupabaseNotConfiguredHint =
      'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.';
  static const rmsBridgeSupabaseTableLabel = 'Supabase table';
  static const rmsBridgeSupabaseTableTooltip =
      'Target table in Supabase for this model.';
  static const rmsBridgeSupabaseRecordsLabel = 'Supabase records';
  static const rmsBridgeSupabaseRecordsTooltip =
      'Total number of rows in the Supabase table.';
  static const rmsBridgeSupabaseMatchedByCodeLabel = 'Matched by code';
  static const rmsBridgeSupabasePendingRecordsLabel = 'Pending sync';
  static const rmsBridgeSupabasePendingRecordsTooltip =
      'How many items will be inserted/updated in this preview.';
  static const rmsBridgeSupabaseNoPendingRecords = 'No pending changes.';
  static const rmsBridgeSupabasePendingSectionTitle = 'Pending changes';
  static const rmsBridgeSupabaseIssuesSectionTitle = 'Issues';
  static const rmsBridgeSupabaseLastSyncUserLabel = 'Last sync user';
  static const rmsBridgeSupabaseLastSyncUserTooltip =
      'User who ran the last sync (placeholder for now).';
  static const rmsBridgeSupabaseLastSyncAtLabel = 'Last sync at';
  static const rmsBridgeSupabaseLastSyncAtTooltip =
      'Timestamp of the last sync (placeholder for now).';
  static const rmsBridgeSupabaseLatestRowAtLabel = 'Latest record at';
  static const rmsBridgeSupabaseLatestRowAtTooltip =
      'created_at timestamp of the newest row in Supabase.';
  static const rmsBridgeSupabaseInsertLabel = 'Insert';
  static const rmsBridgeSupabaseInsertTooltip =
      'How many new rows will be inserted into Supabase.';
  static const rmsBridgeSupabaseUpdateLabel = 'Update';
  static const rmsBridgeSupabaseUpdateTooltip =
      'How many existing rows will be updated in Supabase.';
  static const rmsBridgeSupabaseSkipLabel = 'Skip';
  static const rmsBridgeSupabaseSkipTooltip =
      'How many items already match Supabase and will be skipped.';
  static const rmsBridgeSupabaseConflictsLabel = 'Conflicts';
  static const rmsBridgeSupabaseConflictsTooltip =
      'Conflicting items in the source list (e.g. duplicate codes).';
  static const rmsBridgeSupabaseConflictLabel = 'Conflict';
  static const rmsBridgeSupabaseNullCodesLabel = 'Null codes';
  static const rmsBridgeSupabaseNullCodesTooltip =
      'How many Supabase rows have code = NULL.';
  static const rmsBridgeSupabaseDuplicateCodesLabel = 'Duplicate codes';
  static const rmsBridgeSupabaseDuplicateCodesTooltip =
      'How many duplicated non-null codes exist in Supabase.';
  static const rmsBridgeSupabaseCodeUniqueLabel = 'Code unique';
  static const rmsBridgeSupabaseCodeUniqueTooltip =
      'Derived from the data (no duplicated non-null codes found).';
  static const rmsBridgeSupabaseWarningsTitle = 'Warnings';
  static const rmsBridgeSupabaseWarningNullCodes = 'Null codes in Supabase';
  static const rmsBridgeSupabaseWarningDuplicateCodes =
      'Duplicate codes in Supabase';
  static const rmsBridgeSupabaseWarningConflicts = 'Conflicts in source list';
  static const rmsBridgeSupabaseInsertActionTooltip =
      'This row will be inserted in Supabase.';
  static const rmsBridgeSupabaseUpdateActionTooltip =
      'This row will update an existing Supabase row.';
  static const rmsBridgeSupabaseConflictActionTooltip =
      'This row has a conflict and will not be synced.';
  static const rmsBridgeSupabaseTooltipFieldLabel = 'Field';
  static const rmsBridgeSupabaseTooltipFromLabel = 'From';
  static const rmsBridgeSupabaseTooltipToLabel = 'To';
  static const rmsBridgeSupabaseFieldName = 'name';
  static const rmsBridgeSupabaseApplySyncButton = 'Sync now';
  static const rmsBridgeSupabaseSyncingButton = 'Syncing...';
  static const rmsBridgeSupabaseSyncingInlineMessage =
      'Please wait, syncing data...';
  static const rmsBridgeSupabaseSyncConfirmTitle = 'Confirm Sync';
  static const rmsBridgeSupabaseSyncConfirmMessage =
      'This will apply changes to Supabase.';
  static const rmsBridgeSupabaseSyncResultTitle = 'Sync Result';
  static const rmsBridgeSupabaseSyncDisabledIssuesTooltip =
      'Fix issues first (red items) before syncing.';
  static const rmsBridgeSupabaseSyncDisabledNoChangesTooltip =
      'No pending changes to sync.';
  static const rmsBridgeSupabaseErrorsLabel = 'Errors';
  static const rmsBridgeSupabaseSampleErrorsLabel = 'Error details';
  static const rmsBridgeSupabaseErrorLabel = 'Error';
  static const rmsBridgeBullet = '•';
  static const rmsBridgeItemsCountLabel = 'Items';
  static const rmsBridgeCheckingSession = 'Checking RMS session...';

  static const rmsBridgeReservationIdLabel = 'Reservation ID:';
  static const rmsBridgeReservationNoLabel = 'Reservation No:';
  static const rmsBridgeClientIdLabel = 'Client ID:';
  static const rmsBridgeOpenDetailsButton = 'Open details';
  static const rmsBridgeHotelsPreviewTitle = 'Hotels';
  static const rmsBridgeNoHotelsFound = 'No hotels found in this reservation.';
  static const rmsBridgeUnnamedHotel = 'Hotel';

  static const reservationMainInfoTitle = 'Reservation main info';
  static const reservationDetailsTitle = 'Reservation details';
  static const ppsResNumber = 'PPS Res Number';
  static const ppsResNumberLabel = 'PPS Res Number:';
  static const client = 'Client';
  static const fromDate = 'From date';
  static const toDate = 'To date';
  static const guestName = 'Guest name';
  static const clientOptionDate = 'Client option date';
  static const rmsInvoiceNo = 'RMS invoice no.';

  static const editInfoTitle = 'Edit Info';
  static const editInfoTooltip = 'Edit info';
  static const edit = 'Edit';
  static const close = 'Close';
  static const save = 'Save';
  static const saved = 'Saved';

  static const rmsInvoiceDialogTitle = 'RMS invoice number';
  static const rmsInvoiceDialogHint =
      'Enter RMS invoice number to show it on the PDF (optional).';
  static const continueWithout = 'Continue without';
  static const saveAndPrint = 'Save & Print';
  static const rmsInvoiceMissingColumn =
      'Missing reservation_orders RMS invoice column in database.';
  static const rmsInvoiceIndicatorTooltip =
      'RMS invoice no. محفوظ في قاعدة البيانات وبيظهر في الـ PDF.';

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

  static const reservationIdLabel = ppsResNumberLabel;
  static const creatorLabel = 'Creator:';
  static const dateLabel = 'Date:';

  static const ok = 'OK';
  static const more = 'المزيد';

  static const actions = 'Actions';
  static const addAgentDirect = 'Add Agent Direct';
  static const addGeneral = 'Add General';
  static const addTransport = 'Add Transport';
  static const print = 'Print';
  static const print2 = 'Print 2 — Mix detailed';
  static const print1Summary = 'Print 1 — Simple';
  static const print2Summary = 'Print 2 — Mix detailed';
  static const printUsageTitle =
      'شرح استخدام Print 1 (Simple) و Print 2 (Mix detailed)';
  static const printUsageBodyAr =
      'هشرح لك الموضوع كأنك أول مرة تستخدم النظام (بالعربي البسيط):\n'
      '\n'
      '1) يعني إيه (Qty / Nights / PAX)؟\n'
      '- Qty: عدد الغرف.\n'
      '- Nights: عدد الليالي.\n'
      '- PAX: عدد الأشخاص اللي الحساب بيتوزع عليهم.\n'
      '\n'
      '2) أهم قاعدة في الفاتورة\n'
      '- إجمالي الفاتورة (Total) = مجموع Total sale لكل الخدمات في الحجز.\n'
      '- جدول الغرف في الـ PDF وظيفته يشرح التوزيع، لكن رقم Total النهائي لازم يطابق الفاتورة.\n'
      '\n'
      '3) Party Pax (Manual) ده إيه؟\n'
      '- رقم اختياري إنت بتكتبه بنفسك.\n'
      '- المقصود منه: عدد المسافرين الحقيقي.\n'
      '- لو كتبته: بيتستخدم لتوزيع الإضافات (Add-ons) فقط.\n'
      '- لو ما كتبتهوش: النظام بيستخدم Qty Pax (محسوبة من توزيع الغرف) علشان يوزع الإضافات.\n'
      '\n'
      '4) النقطة الحمرا جنب Party Pax (Manual) معناها إيه؟\n'
      '- معناها فيه اختلاف بين PAX الفعلي داخل سيجمنتات الفنادق وبين الرقم اللي إنت كاتبه.\n'
      '- مثال: إنت كاتب 105، وسيجمنت مكة طالع 107.\n'
      '\n'
      '5) Print 1 — Simple بيستخدم إمتى؟\n'
      '- لما توزيع الغرف ثابت بين MED و MAK.\n'
      '- شرطه: مجموع Qty لكل نوع غرفة في MED لازم يساوي مجموع Qty لنفس النوع في MAK.\n'
      '- لو الشرط مش متحقق: Print 1 بيرفض وبيقولك استخدم Print 2.\n'
      '- Qty في Print 1 = أكبر عدد غرف ظهر في أي يوم (Max) بعد تجميع الأيام.\n'
      '\n'
      '6) Print 2 — Mix detailed بيستخدم إمتى؟\n'
      '- لما توزيع الغرف مختلف بين المدن أو الفترات.\n'
      '- بيقسم صفوف الغرف حسب (المدينة + فترة التواريخ) وقت اختلاف التوزيع.\n'
      '- لو نفس نوع الغرفة له نفس Qty في المدينة ومكة: ممكن يطلع صف واحد.\n'
      '\n'
      '7) توزيع الإضافات في Print 2 (آخر تحديث)\n'
      '- الإضافات (General + Transportation) بتتوزع على الليالي علشان ما تتضاعفش بين المدن لنفس المجموعة.\n'
      '- النظام بيطلع لك داخل الـ PDF: Add-ons divisor (Manual أو Qty Pax) + Add-ons / Pax / Night.\n'
      '- لو عايز مثال بالأرقام (Q&A): افتح زر Print Q&A جنب زر الطباعة.\n'
      '\n'
      'معلومة مهمة عن "Qty اللي بيبان ضعف":\n'
      '- Print 1 ما بيفصلش حسب المدينة، ولو عندك سيجمنتين بنفس التواريخ (overlap) لنفس نوع الغرفة، Qty في اليوم ده بيتجمع وممكن يبان أكبر.\n'
      '- Manual Pax مش بيغير Qty بتاع الغرف، هو بيأثر على توزيع الإضافات فقط.\n';
  static const printUsageBodyEn =
      'Quick guide (English):\n'
      '\n'
      '1) What do (Qty / Nights / PAX) mean?\n'
      '- Qty: number of rooms.\n'
      '- Nights: number of nights.\n'
      '- PAX: number of people the calculation is distributed over.\n'
      '\n'
      '2) Main invoice rule\n'
      '- Invoice Total = sum of Total Sale across all reservation services.\n'
      '- The PDF room table explains distribution, but the final Total must match the invoice.\n'
      '\n'
      '3) What is Party Pax (Manual)?\n'
      '- Optional number representing the real travelers count.\n'
      '- If entered: used to distribute Add-ons only.\n'
      '- If not entered: the system uses Qty Pax (derived from rooms) to distribute Add-ons.\n'
      '\n'
      '4) Red indicator next to Party Pax (Manual)\n'
      '- Means some hotel segments have a different PAX than the manual value.\n'
      '- Example: manual 105 but Makkah segment calculates 107.\n'
      '\n'
      '5) When to use Print 1 — Simple\n'
      '- When room distribution is stable between MED and MAK.\n'
      '- Condition: sum of Qty per room type in MED must equal sum of Qty for the same type in MAK.\n'
      '- If the condition fails: Print 1 is blocked and you should use Print 2.\n'
      '- Qty in Print 1 = maximum rooms on any day (Max) after merging days.\n'
      '\n'
      '6) When to use Print 2 — Mix detailed\n'
      '- When room distribution differs by city/date range.\n'
      '- Rows split by (city + date range) when distribution differs.\n'
      '\n'
      '7) Add-ons distribution in Print 2 (latest)\n'
      '- Add-ons (General + Transportation) are distributed by nights to avoid double counting across cities for the same travelers.\n'
      '- The PDF shows: Add-ons divisor (Manual or Qty Pax) and Add-ons / Pax / Night.\n';

  static const printTotalsHintTooltipEn =
      'The PDF room table is meant to explain accommodation and add-ons distribution (accounting-friendly), but it may not be the best source for a 100% exact invoice total because:\n'
      '- Row-level rounding.\n'
      '- Row merge/split by city and date ranges.\n'
      '- Some services are not rooms (General/Transportation) but are included in the final total.';

  static const printQaTitleAr = 'Print — Q&A (Arabic/English)';
  static const printQaTitleEn = 'Print — Q&A (Arabic/English)';
  static const printQaLanguageAr = 'عربي';
  static const printQaLanguageEn = 'English';
  static const printQaClose = 'Close';
  static const printQaQuestionAr =
      'س: شرح توزيع Add-ons + معنى Total في الـ PDF + ليه ممكن مجموع الصفوف يختلف؟';
  static const printQaQuestionEn =
      'Q: Add-ons distribution + what “Total in the PDF = invoice total” means + why row totals may differ?';

  static const printQaQ1Ar =
      'س: ليه جدول الغرف في الـ PDF مش دايمًا أفضل مصدر لحساب إجمالي الفاتورة بدقة 100%؟';
  static const printQaQ1En =
      'Q: Why isn’t the PDF room table always the best source for a 100% exact invoice total?';
  static const printQaA1Ar =
      'جدول الغرف في الـ PDF هدفه يشرح توزيع السكن والإضافات “بشكل محاسبي مفهوم”، لكنه مش دايمًا أفضل مصدر لحساب إجمالي الفاتورة بدقة 100% بسبب:\n'
      'Rounding على مستوى كل صف.\n'
      'دمج/فصل الصفوف حسب المدينة والفترات.\n'
      'بعض الخدمات مش “غرف” أصلاً (General/Transportation) وهي داخلة في الإجمالي النهائي.';
  static const printQaA1En = printTotalsHintTooltipEn;

  static const printQaQ3Ar =
      'س: معنى “Total في الـ PDF = إجمالي الفاتورة” وهل ممكن مجموع Totals بتاعة الصفوف يختلف؟';
  static const printQaQ3En =
      'Q: What does “Total in the PDF = invoice total” mean, and can row totals differ?';
  static const printQaA3Ar =
      'معنى “Total في الـ PDF = إجمالي الفاتورة”\n'
      '\n'
      'المقصود إن الرقم الكبير اللي تحت (Total) في الـ PDF بقى يُحسب من:\n'
      'sum(details.services.totalSale)\n'
      'ده نفس اللي الشاشة بتعرضه كـ Total sale للحجز.\n'
      'هل ممكن مجموع Totals بتاعة صفوف الجدول يختلف عن Total النهائي؟\n'
      '\n'
      'نعم، وده طبيعي للأسباب دي:\n'
      'تقريب (Rounding): كل صف بيتقرب لوحده (Rate/Pax و Total)، فتجميع التقريبات ممكن يطلع فرق قروش/هللات/ريالات.\n'
      'توزيع داخلي: إحنا بنوزع الإضافات على الصفوف بهدف “شرح وتوزيع”، مش بهدف إن كل صف بعد التقريب يطلع مجموعهم = الرقم النهائي حرفيًا.\n'
      'عدم شمولية جدول الغرف: الجدول هو “تفصيل الفندق”، لكن الإجمالي النهائي شامل كل الخدمات (فندق + إضافات + أي خدمات أخرى).\n';
  static const printQaA3En =
      'What does “Total in the PDF = invoice total” mean?\n'
      '\n'
      'It means the large Total at the bottom of the PDF is computed from:\n'
      'sum(details.services.totalSale)\n'
      'Which is the same Total Sale shown on the reservation details screen.\n'
      'Can the sum of row Totals differ from the final Total?\n'
      '\n'
      'Yes, and that is expected because:\n'
      'Rounding: each row is rounded independently (Rate/Pax and Total), so rounding can accumulate small differences.\n'
      'Internal distribution: rows are meant to explain distribution, not guarantee exact equality after rounding.\n'
      'Room table coverage: the room table is hotel detail, while the final Total includes all services (hotel + add-ons + others).\n';

  static const printQaAnswerAr =
      '(شرح توزيع Add-ons ) تخيل إن عندك:\n'
      '\n'
      'TotalAddOns = إجمالي الإضافات (General + Transportation) = 84,600\n'
      'ManualPax = 105\n'
      'TotalNights = 7 (3 مدينة + 4 مكة)\n'
      'بنقسم الإضافات على الليالي (علشان ما تتكرر بين المدن)\n'
      'بنحسب قيمة “الإضافة للشخص في الليلة”:\n'
      'AddOnsPerPaxPerNight = TotalAddOns / (ManualPax × TotalNights)\n'
      '= 84,600 / (105 × 7)\n'
      '= 115.10 تقريبًا\n'
      'بعد كده كل سيجمنت ياخد نصيبه حسب لياليه\n'
      'سيجمنت المدينة 3 ليالي:\n'
      'SegmentAddOnsTotal = TotalAddOns × (3 / 7)\n'
      'سيجمنت مكة 4 ليالي:\n'
      'SegmentAddOnsTotal = TotalAddOns × (4 / 7)\n'
      'جوا نفس السيجمنت بنوزع الإضافات على أنواع الغرف حسب “سهمها” من TotalSale\n'
      'يعني لو داخل سيجمنت مكة:\n'
      'Quad TotalSale = 56,000\n'
      'Double TotalSale = 28,800\n'
      'Triple TotalSale = 2,600\n'
      'يبقى كل نوع غرفة ياخد نسبة من SegmentAddOnsTotal على قد “مساهمته” في TotalSale.\n'
      'ده بيخلي التوزيع منطقي: الغرفة اللي عليها بيع أكبر تتحمل جزء أكبر من الإضافات داخل نفس السيجمنت.\n'
      'بعد ما عرفنا الإضافة الإجمالية لكل نوع غرفة داخل السيجمنت\n'
      'بنحولها لإضافة “لكل شخص” في الصف:\n'
      'LineAddOnsPerPax = LineAddOnsTotal / PAX#\n'
      'وبعدين:\n'
      'Rate/Pax = BaseRatePerPax + LineAddOnsPerPax\n'
      'TotalLine = Rate/Pax × PAX#\n'
      'ليه ده يمنع تضاعف الإضافات؟\n'
      '\n'
      'لأن TotalAddOns اتقسم مرة واحدة على TotalNights، واتوزع بين المدينة ومكة بحسب الليالي، مش بحسب إنك عندك صفوف في مكانين.\n'
      'معنى “Total في الـ PDF = إجمالي الفاتورة”\n'
      '\n'
      'المقصود إن الرقم الكبير اللي تحت (Total) في الـ PDF بقى يُحسب من:\n'
      'sum(details.services.totalSale)\n'
      'ده نفس اللي الشاشة بتعرضه كـ Total sale للحجز.\n'
      'هل ممكن مجموع Totals بتاعة صفوف الجدول يختلف عن Total النهائي؟\n'
      '\n'
      'نعم، وده طبيعي للأسباب دي:\n'
      'تقريب (Rounding): كل صف بيتقرب لوحده (Rate/Pax و Total)، فتجميع التقريبات ممكن يطلع فرق قروش/هللات/ريالات.\n'
      'توزيع داخلي: إحنا بنوزع الإضافات على الصفوف بهدف “شرح وتوزيع”، مش بهدف إن كل صف بعد التقريب يطلع مجموعهم = الرقم النهائي حرفيًا.\n'
      'عدم شمولية جدول الغرف: الجدول هو “تفصيل الفندق”، لكن الإجمالي النهائي شامل كل الخدمات (فندق + إضافات + أي خدمات أخرى).\n';

  static const printQaAnswerEn =
      '(Add-ons distribution example) Imagine you have:\n'
      '\n'
      'TotalAddOns = total add-ons (General + Transportation) = 84,600\n'
      'ManualPax = 105\n'
      'TotalNights = 7 (3 nights MED + 4 nights MAK)\n'
      'We distribute add-ons by nights (so they do not get double-counted across cities)\n'
      'We calculate “add-ons per pax per night”:\n'
      'AddOnsPerPaxPerNight = TotalAddOns / (ManualPax × TotalNights)\n'
      '= 84,600 / (105 × 7)\n'
      '= ~115.10\n'
      'Then each segment takes its share based on nights:\n'
      'MED segment (3 nights):\n'
      'SegmentAddOnsTotal = TotalAddOns × (3 / 7)\n'
      'MAK segment (4 nights):\n'
      'SegmentAddOnsTotal = TotalAddOns × (4 / 7)\n'
      'Inside the same segment, we distribute add-ons across room types by their “share” of TotalSale\n'
      'Example inside MAK segment:\n'
      'Quad TotalSale = 56,000\n'
      'Double TotalSale = 28,800\n'
      'Triple TotalSale = 2,600\n'
      'So each room type receives a proportion of SegmentAddOnsTotal based on its contribution to TotalSale.\n'
      'This keeps the distribution intuitive: higher-priced room types carry a larger portion of add-ons within the same segment.\n'
      'After we get the total add-ons for each row, we convert it to “per pax”:\n'
      'LineAddOnsPerPax = LineAddOnsTotal / PAX#\n'
      'Then:\n'
      'Rate/Pax = BaseRatePerPax + LineAddOnsPerPax\n'
      'TotalLine = Rate/Pax × PAX#\n'
      'Why does this prevent double counting?\n'
      '\n'
      'Because TotalAddOns is allocated once across TotalNights, then split between MED and MAK by nights, not by having rows in two places.\n'
      'What does “Total in the PDF = invoice total” mean?\n'
      '\n'
      'It means the large Total at the bottom of the PDF is computed from:\n'
      'sum(details.services.totalSale)\n'
      'Which is the same Total Sale shown on the reservation details screen.\n'
      'Can the sum of row Totals differ from the final Total?\n'
      '\n'
      'Yes, and that is expected because:\n'
      'Rounding: each row is rounded independently (Rate/Pax and Total), so rounding can accumulate small differences.\n'
      'Internal distribution: rows are meant to explain distribution, not guarantee exact equality after rounding.\n'
      'Room table coverage: the room table is hotel detail, while the final Total includes all services (hotel + add-ons + others).\n';
  static const printUsageBody = printUsageBodyAr;
  static const calculationsGuide = 'QA';
  static const calculationsGuideBodyAr =
      'Print 1 — Simple:\n'
      '- Qty = أكبر عدد غرف ظهر في أي يوم (Max) بعد تجميع الأيام لكل نوع غرفة.\n'
      '- Nights = مجموع الليالي بدون تكرار لنفس الفترة داخل نفس السيجمنت.\n'
      '- PAX# = Qty × Pax/Room (Single=1, Double=2, Triple=3, Quad=4, Quint=5).\n'
      '- Add-ons / Pax = (إجمالي General + Transportation) ÷ Party Pax.\n'
      '- Party Pax = Manual لو موجود (>0) وإلا Qty Pax (محسوبة من توزيع الغرف).\n'
      '\n'
      'Print 2 — Mix detailed:\n'
      '- صفوف الغرف بتتفصل حسب (المدينة + فترة التواريخ) عند اختلاف التوزيع.\n'
      '- Add-ons بتتوزع على الليالي لتجنب تضاعفها بين المدن لنفس المجموعة.\n'
      '- Total النهائي في الـ PDF = إجمالي الفاتورة (مجموع totalSale لكل الخدمات).\n';
  static const calculationsGuideBody =
      'Print 1 — Simple:\n'
      '- Qty (display) = Max rooms per day after merging hotel segments.\n'
      '- PAX# = Qty × Pax/Room (Double=2, Triple=3, Quad=4, Quint=5).\n'
      '- Add-ons / Pax = (Total Sale of General + Transportation) / Party Pax.\n'
      '- Party Pax = Party Pax (Manual) if entered, otherwise Qty Pax derived from rooms.\n'
      '\n'
      'Print 2 — Mix detailed:\n'
      '- If hotel distribution differs by city/date segment, rows split by (city + date range).\n'
      '- If a room type keeps the same Qty across segments, it stays as a single row.\n'
      '- Add-ons are distributed by nights to avoid double counting across cities.\n'
      '- Final PDF Total equals the invoice total (sum of services.totalSale).\n'
      '\n'
      'Party Pax (Manual):\n'
      '- Optional number you enter to represent the real travelers count.\n'
      '- If any hotel segment has different PAX, the system shows a red warning dot.';

  static const print1SimpleBlockedTitle = 'Print 1 — Simple is not available';
  static const print1SimpleBlockedBodyIntro =
      'لا يمكن استخدام Print 1 — Simple لأن توزيع الغرف مختلف بين المدينة ومكة.\n'
      '\n'
      'الشرط لاستخدام Print 1:\n'
      '- مجموع Qty لكل نوع غرفة في MED لازم يساوي مجموع Qty لنفس النوع في MAK.\n'
      '\n'
      'مثال سريع:\n'
      '- Quad: MED=25 و MAK=25 → ينفع Print 1.\n'
      '- Quad: MED=25 و MAK=20 → لازم Print 2.\n'
      '\n'
      'الاختلافات الحالية:\n';
  static const partyPaxManual = 'Party Pax (Manual)';
  static const partyPaxManualHint =
      'Optional. Used to validate hotel segments and distribute add-ons.';
  static const partyPaxManualIndicatorTooltip =
      'لو فيه سيجمنتات PAX مختلفة عن Party Pax (Manual) هيظهر تحذير.';
  static const warningIndicatorDefaultTooltip = 'تحذير: راجع التفاصيل.';
  static const partyPaxMismatchTitle = 'Party Pax mismatch';
  static const partyPaxMismatchBodyPrefix =
      'Some hotel segments have PAX different from Party Pax (Manual):';
  static const continueAnyway = 'Continue anyway';
  static const fixNow = 'Fix now';
  static const partyPaxMismatchInlineTemplate =
      'Warning: PAX in {place} ({segmentPax}) differs from Party Pax (Manual) ({manualPax})';
  static const generalQtyMismatchTemplate =
      'Warning: General service Qty ({qty}) differs from Party Pax (Manual) ({manualPax}). If Qty represents PAX for this service, review it.';
  static const locationPaxMismatchTemplate =
      'Warning: Total PAX in {place} ({locationPax}) differs from Party Pax (Manual) ({manualPax}).';
  static const locationPaxDifferenceTemplate =
      'Warning: Total PAX in {place} ({placePax}) differs from {otherPlace} ({otherPax}).';
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
  static const location = 'Location';
  static const madinah = 'Madinah';
  static const makkah = 'Makkah';
  static const med = 'MED';
  static const mak = 'MAK';
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

  static const saveFileDialogTitle = 'Save file';
}
