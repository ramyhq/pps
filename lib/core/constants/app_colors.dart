import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(
    0xFF0C66E4,
  ); // Approximated from screenshot/HTML
  static const Color primaryAction = Color(0xFF1976D2);
  static const Color primarySurface = Color(0xFFE3F2FD);
  static const Color primarySurfaceAlt = Color(0xFFEAF3FF);
  static const Color secondary = Color(0xFFE4E6EF);
  static const Color inputBorder = Color(0xFFD5DEEE);
  static const Color success = Color(0xFF50CD89);
  static const Color actionGreen = Color(0xFF198754);
  static const Color info = Color(0xFF7239EA);
  static const Color warning = Color(0xFFFFC700);
  static const Color danger = Color(0xFFF1416C);
  static const Color dangerAccent = Color(0xFFF44336);
  static const Color dark = Color(0xFF181C32);
  static const Color light = Color(0xFFF5F8FA);
  static const Color disabledFill = Color(0xFFF7FAFC);
  static const Color checkboxBorder = Color(0xFFCFD3DA);
  static const Color textPrimary = Color(0xFF181C32);
  static const Color textSecondary = Color(0xFF7E8299);
  static const Color border = Color(0xFFEFF2F5);
  static const Color tableHeader = Color(0xFFF9F9F9);
  static const Color white = Colors.white;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle value = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}

class AppFontSizes {
  /// Page title for list pages (e.g., "Reservations" list).
  static const double pageTitle24 = 24;

  /// Screen/toolbar title for details pages.
  static const double title20 = 20;

  /// Logo/brand heading and large section titles.
  static const double heading18 = 18;

  /// Dialog title and prominent headings inside cards.
  static const double title14 = 14;

  /// Accordion/header titles.
  static const double title13 = 13;

  /// Default body/value text across the app.
  static const double body12 = 12;

  /// Field labels and secondary meta text (dense UI).
  static const double label11 = 11;

  /// Small badges/chips text.
  static const double badge10 = 10;

  /// Extra-small counters (e.g., notification bubble).
  static const double tiny8 = 8;
}

class AppSpacing {
  /// Use this scale for gaps/paddings instead of hardcoded numbers.
  static const double s0 = 0;
  static const double s2 = 2;
  static const double s3 = 3;
  static const double s4 = 4;
  static const double s5 = 5;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s30 = 30;
  static const double s32 = 32;
  static const double s40 = 40;
}

class AppFonts {
  static const String family = 'Helvetica';
}

class AppRadii {
  /// Extra-compact radius (e.g., small square badges/icons).
  static const double r2 = 2;

  /// Compact chip radius (e.g., type pill).
  static const double r3 = 3;

  /// Default control/card radius in compact UI.
  static const double r4 = 4;

  /// Default accordion/dialog radius in details pages.
  static const double r6 = 6;

  /// Hoverable menu item radius.
  static const double r8 = 8;

  /// Popup menu radius.
  static const double r12 = 12;
  static const double r20 = 20;
}

class AppHeights {
  /// App header height (Shell layout).
  static const double header60 = 60;

  /// Standard compact buttons in toolbars and dialogs.
  static const double button32 = 32;

  /// Standard compact input height (used in create screens and details forms).
  static const double field34 = 34;

  /// Dropdown search field height inside overlay.
  static const double dropdownSearch30 = 30;

  /// Dropdown item height inside overlay list.
  static const double dropdownItem28 = 28;

  /// Compact grid input height.
  static const double cell24 = 24;

  /// Standard searchable dropdown max height.
  static const double dropdownPopupMax180 = 180;

  /// Actions popup menu item height.
  static const double menuItem40 = 40;

  /// Small pills/chips height.
  static const double chip16 = 16;

  /// Compact icon-button square sizes.
  static const double iconButton24 = 24;
  static const double iconButton28 = 28;
}

class AppIconSizes {
  static const double s12 = 12;
  static const double s13 = 13;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
}

class AppDurations {
  /// Compact micro-interactions (accordions, chevrons, etc.).
  static const Duration accordion = Duration(milliseconds: 120);
}

class AppAlphas {
  /// Use for subtle surfaces (chips/pills).
  static const double surface15 = 0.15;

  /// Use for very subtle hover on solid primary buttons.
  static const double hover08 = 0.08;

  /// Use for hover backgrounds.
  static const double hover26 = 0.26;

  /// Use for heavy shadows.
  static const double shadow28 = 0.28;

  /// Use for subtle separators.
  static const double separator35 = 0.35;
}

class AppElevations {
  /// Popup menus and floating surfaces.
  static const double menu = 16;
}

class AppInsets {
  /// Standard page padding for Details screens (like ReservationDetailsScreen).
  static const EdgeInsets pageDetails = EdgeInsets.fromLTRB(
    AppSpacing.s12,
    AppSpacing.s8,
    AppSpacing.s12,
    AppSpacing.s12,
  );

  /// Default card body padding for compact cards on details pages.
  static const EdgeInsets cardBody10 = EdgeInsets.all(AppSpacing.s10);

  /// Section header padding for compact cards (e.g., "Reservation details").
  static const EdgeInsets sectionHeader = EdgeInsets.symmetric(
    horizontal: AppSpacing.s12,
    vertical: AppSpacing.s8,
  );

  /// Accordion header padding.
  static const EdgeInsets accordionHeader = EdgeInsets.symmetric(
    horizontal: AppSpacing.s8,
    vertical: AppSpacing.s6,
  );

  /// Accordion body padding.
  static const EdgeInsets accordionBody = EdgeInsets.fromLTRB(
    AppSpacing.s8,
    AppSpacing.s6,
    AppSpacing.s8,
    AppSpacing.s8,
  );

  /// Compact form field content padding.
  static const EdgeInsets inputContent = EdgeInsets.symmetric(
    horizontal: AppSpacing.s12,
    vertical: AppSpacing.s10,
  );

  static const EdgeInsets inputContentDense = EdgeInsets.symmetric(
    horizontal: AppSpacing.s10,
    vertical: AppSpacing.s10,
  );
}

class AppWidths {
  static const double sidebar = 250;
  static const double headerSearch = 200;
  static const double dropdownFallbackFieldWidth = 260;
  static const double datePickerPopup = 300;
}

class AppDatePickerLayout {
  static const double navButtonSize = 22;
  static const double dayCellSize = 28;
}

class AppTimePickerLayout {
  static const double minPopupWidth = 140;
  static const double spinnerWidth = 44;
  static const double arrowButtonHeight = 22;
  static const double valueHeight = 28;
}

class AppBreakpoints {
  /// Reservation details desktop layout threshold (4-column grid).
  static const double detailsDesktop = 980;

  /// Shell layout: below this width we hide the sidebar and use a drawer.
  static const double shellMobile = 900;

  /// Dialog layout thresholds used in details edit dialogs.
  static const double dialogMd = 520;
  static const double dialogLg = 760;
}

class CreateScreensBreakpoints {
  static const double desktop = 900;
  static const double wide = 1000;
  static const double largeDesktop = 1300;
  static const double xlDesktop = 1450;
  static const double mdDesktop = 1200;
}

class CreateScreensLayout {
  static const double arrivalWidthXl = 280;
  static const double arrivalWidthMd = 250;
  static const double arrivalWidthSm = 220;
  static const double nightsWidthMd = 90;
  static const double nightsWidthSm = 78;

  static const double clientWidthXl = 380;
  static const double clientWidthMd = 340;
  static const double clientWidthSm = 300;

  static const double dateColumnWidth = 180;
  static const double headerHeight32 = 32;
  static const double cellHeight28 = 28;
  static const double checkboxTopPadding26 = 26;
  static const double radioTopPadding22 = 22;

  static const double pricingTableMaxWidth900 = 900;
  static const double pricingLabelColWidth90 = 90;
  static const double tripQuantityWidthMd120 = 120;
  static const double tripQuantityWidthSm110 = 110;
}

class ReservationDetailsLayout {
  /// Main info wrap widths (mobile/compact fallback).
  static const double mainInfoClientWidth = 230;
  static const double mainInfoFromWidth = 145;
  static const double mainInfoToWidth = 145;
  static const double mainInfoTypeWidth = 120;
  static const double mainInfoGuestWidth = 230;
  static const double mainInfoOptionDateWidth = 195;

  /// Edit dialog layout.
  static const double editDialogMaxWidth = 1100;
  static const double editDialogMaxHeightRatio = 1.85;
  static const double editDialogMinHeight = 320;

  static const double editClientWidthLg = 420;
  static const double editClientWidthMd = 360;
  static const double editGuestWidthLg = 230;
  static const double editGuestWidthMd = 220;
  static const double editDateWidthLg = 190;
  static const double editDateWidthMd = 180;

  /// Reservation details service info column widths.
  static const double serviceColumnWide = 260;
  static const double serviceColumnMedium = 200;
  static const double serviceColumnCompact = 160;

  /// Actions popup menu sizing.
  static const double actionsMenuExtraWidth = 34;
  static const double actionsMenuMinWidth = 185;
  static const double actionsMenuMaxWidth = 215;
  static const double actionsMenuDividerWidth = 150;
  static const double actionsMenuDividerHeight = 1;

  /// Table column widths (Room details).
  static const double roomTypeCol = 140;
  static const double priceCol = 120;
  static const double totalCol = 90;
}
