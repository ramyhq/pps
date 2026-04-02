import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pps/core/constants/app_strings.dart';
import 'package:pps/features/reservations/data/models/reservation_details.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/data/models/reservation_service.dart';

class ReservationDetailsPdfGenerator {
  static const String _companyNameEn =
      'SAHL Saudi Accommodation & Handling Labor';
  static const String _companyNameAr = 'شركة سهل الفندقية';

  static const String _logoAssetPath = 'assets/images/sahl_logo.jpg';

  static const String _addressLine1 =
      'Unit NO: 14, 3rd floor, above Al Safa Medical center, Mehriz Bin Alwaddah street, King ,3937';
  static const String _addressLine2 = 'Abdulaziz road, Madinah, KSA';

  static const String _bankAccountName = 'SAHL for Hotel Management';
  static const String _bankName = 'Al Rajhi';
  static const String _bankBranch = '-';
  static const String _bankAccountNumber = '55300-001-0006086136468';
  static const String _bankIban = 'SA5980000553608016136468';
  static const String _bankSwift = 'RJHISARI';

  static const PdfColor _tableBorderColor = PdfColor.fromInt(0xFFD4D4D4);
  static const PdfColor _tableHeaderColor = PdfColor.fromInt(0xFFD4D4D4);
  static const PdfColor _zebraRowColor = PdfColor.fromInt(0xFFF6F6F6);
  static const PdfColor _statusGrey = PdfColor.fromInt(0xFFC0C0C0);

  static Future<Uint8List> buildPdf(ReservationDetails details) async {
    final logo = await imageFromAssetBundle(_logoAssetPath);

    final arialRegularData = await rootBundle.load('assets/fonts/arial.ttf');
    final arialBoldData = await rootBundle.load('assets/fonts/arialbd.ttf');
    final arialRegular = pw.Font.ttf(arialRegularData);
    final arialBold = pw.Font.ttf(arialBoldData);

    final theme = pw.ThemeData.withFont(base: arialRegular, bold: arialBold);

    final doc = pw.Document(theme: theme);
    final agentServices = details.services
        .where((s) => s.type == ReservationServiceType.agent)
        .toList();
    final transportationServices = details.services
        .where((s) => s.type == ReservationServiceType.transportation)
        .toList();
    final generalServices = details.services
        .where((s) => s.type == ReservationServiceType.general)
        .toList();

    final additionalPerPax = _additionalPerPax(
      transportationServices: transportationServices,
      generalServices: generalServices,
    );
    final roomLines = _roomLines(agentServices, additionalPerPax);
    final totalSale = _sumMoney(details.services.map((s) => s.totalSale));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        footer: (context) => _footer(context),
        build: (context) => [
          _topHeader(logo: logo),
          pw.SizedBox(height: 8),
          _topInfoSection(details.order),
          pw.SizedBox(height: 8),
          _reservationHotelsTable(agentServices),
          pw.SizedBox(height: 14),
          _roomPricingTable(roomLines),
          _servicesSection(
            transportationServices: transportationServices,
            agentServices: agentServices,
            generalServices: generalServices,
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Total:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Text(
                  _formatMoney(totalSale),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.NewPage(),
          _topHeader(logo: logo),
          pw.SizedBox(height: 14),
          _termsAndConditions(details.services),
          pw.SizedBox(height: 12),
          _cancellationPolicy(),
          pw.SizedBox(height: 14),
          _bankAccount(),
          pw.SizedBox(height: 16),
          _signature(),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _servicesSection({
    required List<ReservationServiceSummary> transportationServices,
    required List<ReservationServiceSummary> agentServices,
    required List<ReservationServiceSummary> generalServices,
  }) {
    final hasTransportation = transportationServices
        .expand((s) => s.transportationDetails?.trips ?? const [])
        .isNotEmpty;
    final hasOtherServices = _otherServicesOrderedList(
      agentServices: agentServices,
      generalServices: generalServices,
    ).isNotEmpty;

    if (!hasTransportation && !hasOtherServices) {
      return pw.SizedBox.shrink();
    }

    if (hasTransportation && hasOtherServices) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _transportationTable(transportationServices)),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: _otherServicesTable(agentServices, generalServices),
            ),
          ],
        ),
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16),
      child: hasTransportation
          ? _transportationTable(transportationServices)
          : _otherServicesTable(agentServices, generalServices),
    );
  }

  static pw.Widget _topHeader({required pw.ImageProvider logo}) {
    return pw.Column(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _companyNameEn,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Directionality(
                      textDirection: pw.TextDirection.rtl,
                      child: pw.Text(
                        _companyNameAr,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(
                width: 140,
                child: pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Image(
                    logo,
                    width: 190,
                    height: 70,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(height: 2, color: PdfColors.black),
      ],
    );
  }

  static pw.Widget _topInfoSection(ReservationOrder order) {
    final dateText = DateFormat('dd/MM/yyyy').format(order.createdAt);
    final optionDateText = _formatDate(order.clientOptionDate);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Stack(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(
                right: 200,
                left: 6,
                top: 8,
                bottom: 14,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 50,
                        child: pw.Text(
                          'Date:',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        dateText,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 50,
                        child: pw.Text(
                          'To:',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        order.client.name,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Positioned(
              right: 0,
              top: 6,
              child: pw.Opacity(
                opacity: 0.35,
                child: pw.Text(
                  'Tentative\nConfirmation',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _statusGrey,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: PdfColors.black),
        pw.SizedBox(height: 6),
        pw.Text(
          'Thank you for showing your interest in $_companyNameEn',
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 70,
                    child: pw.Text(
                      'Res. No:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    order.reservationNo.toString(),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 95,
                    child: pw.Text(
                      'Option date:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    optionDateText,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 70,
                    child: pw.Text(
                      'Guest name:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    order.guestName ?? '',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _reservationHotelsTable(
    List<ReservationServiceSummary> agentServices,
  ) {
    final headerStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    const cellStyle = pw.TextStyle(fontSize: 10.5);

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _tableHeaderColor),
        children: [
          _cell('RSV #', headerStyle, align: pw.Alignment.centerLeft),
          _cell('City', headerStyle, align: pw.Alignment.centerLeft),
          _cell('Hotel Name', headerStyle, align: pw.Alignment.centerLeft),
          _cell('Arrival date', headerStyle, align: pw.Alignment.centerLeft),
          _cell('Depart. date', headerStyle, align: pw.Alignment.centerLeft),
          _cell('Nights', headerStyle, align: pw.Alignment.centerLeft),
        ],
      ),
    ];

    String baseReservationNo(String raw) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        return '-';
      }
      final parts = trimmed.split('-');
      return parts.isEmpty ? trimmed : parts.first;
    }

    final acc = <String, _HotelSegmentLine>{};
    for (final service in agentServices) {
      final a = service.agentDetails;
      if (a == null) {
        continue;
      }
      final hotelKey = (a.hotelId ?? a.hotelName ?? '').toString().trim();
      final key =
          '${hotelKey}__${a.arrivalDate.millisecondsSinceEpoch}__${a.departureDate.millisecondsSinceEpoch}';
      acc.putIfAbsent(
        key,
        () => _HotelSegmentLine(
          reservationNo: baseReservationNo(service.displayNo),
          city: a.hotelCity?.trim().isNotEmpty == true
              ? a.hotelCity!.trim()
              : '-',
          hotelName: a.hotelName?.trim().isNotEmpty == true
              ? a.hotelName!.trim()
              : '-',
          arrivalDate: a.arrivalDate,
          departureDate: a.departureDate,
        ),
      );
    }

    final segments = acc.values.toList()
      ..sort((a, b) {
        final byArrival = a.arrivalDate.compareTo(b.arrivalDate);
        if (byArrival != 0) {
          return byArrival;
        }
        return a.hotelName.compareTo(b.hotelName);
      });

    for (var index = 0; index < segments.length; index++) {
      final seg = segments[index];
      final nights = seg.departureDate.difference(seg.arrivalDate).inDays;
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: index.isOdd ? _zebraRowColor : PdfColors.white,
          ),
          children: [
            _cell(seg.reservationNo, cellStyle),
            _cell(seg.city, cellStyle),
            _cell(seg.hotelName, cellStyle),
            _cell(_formatDate(seg.arrivalDate), cellStyle),
            _cell(_formatDate(seg.departureDate), cellStyle),
            _cell(nights.toString(), cellStyle, align: pw.Alignment.centerLeft),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _tableBorderColor, width: 0.8),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.9),
        1: pw.FlexColumnWidth(1.6),
        2: pw.FlexColumnWidth(4.0),
        3: pw.FlexColumnWidth(1.6),
        4: pw.FlexColumnWidth(1.6),
        5: pw.FlexColumnWidth(0.9),
      },
      children: rows,
    );
  }

  static pw.Widget _roomPricingTable(List<_RoomLine> lines) {
    final headerStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.normal,
    );
    final cellStyle = const pw.TextStyle(fontSize: 10.5);

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _tableHeaderColor),
        children: [
          _cell('Room Type', headerStyle),
          _cell('M / P', headerStyle),
          _cell('Qty', headerStyle),
          _cell('Nights', headerStyle),
          _cell('PAX #', headerStyle),
          _cell('Rate / Pax', headerStyle),
          _cell('Total', headerStyle),
        ],
      ),
      for (var index = 0; index < lines.length; index++)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: index.isOdd ? _zebraRowColor : PdfColors.white,
          ),
          children: [
            _cell(lines[index].roomType, cellStyle),
            _cell(lines[index].mealPlan, cellStyle),
            _cell(lines[index].qty.toString(), cellStyle),
            _cell(lines[index].nights.toString(), cellStyle),
            _cell(lines[index].pax.toString(), cellStyle),
            _cell(_formatMoney(lines[index].ratePerPax), cellStyle),
            _cell(_formatMoney(lines[index].total), cellStyle),
          ],
        ),
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _tableBorderColor, width: 0.8),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.2),
        1: pw.FlexColumnWidth(2.5),
        2: pw.FlexColumnWidth(0.9),
        3: pw.FlexColumnWidth(1.0),
        4: pw.FlexColumnWidth(1.1),
        5: pw.FlexColumnWidth(1.6),
        6: pw.FlexColumnWidth(1.7),
      },
      children: rows,
    );
  }

  static pw.Widget _transportationTable(
    List<ReservationServiceSummary> transportationServices,
  ) {
    final headerStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );
    final tableHeaderStyle = pw.TextStyle(
      fontSize: 10.5,
      fontWeight: pw.FontWeight.bold,
    );
    final cellStyle = const pw.TextStyle(fontSize: 10.5);

    final trips = transportationServices
        .expand((s) => s.transportationDetails?.trips ?? const [])
        .toList();

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _tableHeaderColor),
        children: [
          _cell('From', tableHeaderStyle),
          _cell('To', tableHeaderStyle),
        ],
      ),
      if (trips.isEmpty)
        pw.TableRow(children: [_cell('-', cellStyle), _cell('-', cellStyle)])
      else
        for (var index = 0; index < trips.length; index++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isOdd ? _zebraRowColor : PdfColors.white,
            ),
            children: [
              _cell(
                _formatLocationCode(trips[index].fromDestination),
                cellStyle,
              ),
              _cell(_formatLocationCode(trips[index].toDestination), cellStyle),
            ],
          ),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Transportation', style: headerStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _tableBorderColor, width: 0.8),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.0),
            1: pw.FlexColumnWidth(1.0),
          },
          children: rows,
        ),
      ],
    );
  }

  static List<String> _otherServicesOrderedList({
    required List<ReservationServiceSummary> agentServices,
    required List<ReservationServiceSummary> generalServices,
  }) {
    final otherServices = <String>{};
    for (final s in generalServices) {
      final name = s.generalDetails?.serviceName.trim();
      if (name != null && name.isNotEmpty) {
        otherServices.add(name);
      }
    }
    final hasMeal = agentServices.any((s) {
      final details = s.agentDetails;
      final mp = details?.selectedMealPlan?.trim();
      return mp != null && mp.isNotEmpty;
    });
    if (hasMeal) {
      otherServices.add('Meal');
    }

    final preferredOrder = <String>[
      'Visa',
      'Mutawif',
      'UmrahFullPackage',
      'ARRIVALHANDLING',
      'MEDHTLCHECKIN',
      'MEDMAZARATHANDLING',
      'MEDHTLCHECKOUT',
      'MAKHTLCHECKIN',
      'MAKMAZARATHANDLING',
      'DEPARTUREHANDLING',
      'Meal',
    ];

    final normalized = {
      for (final s in otherServices) _normalizeServiceName(s): s,
    };

    final ordered = <String>[
      for (final pref in preferredOrder)
        if (normalized.containsKey(_normalizeServiceName(pref)))
          normalized[_normalizeServiceName(pref)]!,
      ...otherServices.where((s) {
        final n = _normalizeServiceName(s);
        return !preferredOrder.any((p) => _normalizeServiceName(p) == n);
      }).toList()..sort(),
    ];

    return ordered;
  }

  static pw.Widget _otherServicesTable(
    List<ReservationServiceSummary> agentServices,
    List<ReservationServiceSummary> generalServices,
  ) {
    final headerStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final tableHeaderStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final cellStyle = const pw.TextStyle(fontSize: 10.5);

    final ordered = _otherServicesOrderedList(
      agentServices: agentServices,
      generalServices: generalServices,
    );

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _tableHeaderColor),
        children: [_cell('Service', tableHeaderStyle)],
      ),
      if (ordered.isEmpty)
        pw.TableRow(children: [_cell('-', cellStyle)])
      else
        for (var index = 0; index < ordered.length; index++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isOdd ? _zebraRowColor : PdfColors.white,
            ),
            children: [_cell(_prettyServiceName(ordered[index]), cellStyle)],
          ),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Other Services', style: headerStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _tableBorderColor, width: 0.8),
          columnWidths: const {0: pw.FlexColumnWidth(1)},
          children: rows,
        ),
      ],
    );
  }

  static pw.Widget _termsAndConditions(
    List<ReservationServiceSummary> services,
  ) {
    final displayNos = services
        .map((s) => s.displayNo)
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final displayNosLabel = displayNos.isEmpty ? '-' : displayNos.join(' & ');
    final selectedKey = _resolveTermsAndConditionsKey(services);
    final termsText =
        AppStrings.termsAndConditionsTemplates[selectedKey] ??
        AppStrings.termsAndConditionsTemplates[AppStrings
            .termsAndConditionsDefaultKey] ??
        '-';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Terms & Conditions : ($displayNosLabel)',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 6),
        _termsBody(termsText),
      ],
    );
  }

  static pw.Widget _termsBody(String raw) {
    final lines = raw
        .split('\n')
        .map((l) => l.replaceAll('\uFEFF', '').trim())
        .where((l) => l.isNotEmpty)
        .toList(growable: false);

    pw.TextStyle lineStyle({bool bold = false}) {
      return pw.TextStyle(
        fontSize: 12,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        height: 1.25,
      );
    }

    bool isStrongLine(String line) {
      final t = line.trim();
      if (t.isEmpty) return false;
      if (t.endsWith(':')) return true;
      return t.toUpperCase() == t && t.length >= 6;
    }

    pw.Widget asBullet(String text) {
      final normalized = text.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim();
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 14,
            child: pw.Text('•', style: lineStyle(bold: true)),
          ),
          pw.Expanded(child: pw.Text(normalized, style: lineStyle())),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          if (RegExp(r'^[•\-\*]\s+').hasMatch(line))
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10),
              child: asBullet(line),
            )
          else
            pw.Text(line, style: lineStyle(bold: isStrongLine(line))),
      ],
    );
  }

  static String _resolveTermsAndConditionsKey(
    List<ReservationServiceSummary> services,
  ) {
    final keys = <String>{};
    for (final s in services) {
      final generalKey = s.generalDetails?.termsAndConditions?.trim();
      if (generalKey != null && generalKey.isNotEmpty) {
        keys.add(generalKey);
      }
      final transportationKey = s.transportationDetails?.termsAndConditions
          ?.trim();
      if (transportationKey != null && transportationKey.isNotEmpty) {
        keys.add(transportationKey);
      }
    }
    if (keys.isEmpty) {
      return AppStrings.termsAndConditionsDefaultKey;
    }
    if (keys.length == 1) {
      return keys.first;
    }
    return keys.first;
  }

  static pw.Widget _cancellationPolicy() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Cancellation policy',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 6),
        _termsBody(_cancellationText),
      ],
    );
  }

  static pw.Widget _bankAccount() {
    pw.Widget rowCells(String label, String value) {
      return pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Our Bank Account:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 6),
        rowCells('Account name:', _bankAccountName),
        rowCells('Bank name:', _bankName),
        rowCells('Branch:', _bankBranch),
        rowCells('Account #:', _bankAccountNumber),
        rowCells('IBAN #:', _bankIban),
        rowCells('Swift Code:', _bankSwift),
      ],
    );
  }

  static pw.Widget _signature() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Thanks, and Best Regards',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Mohamed Diab',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 8),
        pw.Text(
          _addressLine1,
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text(
          _addressLine2,
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
      ],
    );
  }

  static pw.Widget _cell(
    String text,
    pw.TextStyle style, {
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(text, style: style),
    );
  }

  static int _partyPax(List<ReservationServiceSummary> agentServices) {
    final segmentPax = <String, int>{};
    for (final s in agentServices) {
      final a = s.agentDetails;
      if (a == null) {
        continue;
      }
      final hotelKey = (a.hotelId ?? a.hotelName ?? '').toString().trim();
      final key =
          '${hotelKey}__${a.arrivalDate.millisecondsSinceEpoch}__${a.departureDate.millisecondsSinceEpoch}';
      segmentPax[key] = (segmentPax[key] ?? 0) + a.totalPax;
    }
    var maxPax = 0;
    for (final pax in segmentPax.values) {
      if (pax > maxPax) {
        maxPax = pax;
      }
    }
    return maxPax;
  }

  static List<_RoomLine> _roomLines(
    List<ReservationServiceSummary> agentServices,
    Decimal additionalPerPax,
  ) {
    final partyPax = _partyPax(agentServices);
    final Map<String, _RoomLineAccumulator> acc = {};
    for (final s in agentServices) {
      final a = s.agentDetails;
      if (a == null) {
        continue;
      }
      for (final room in a.roomsSummary) {
        final key = '${room.roomType}__${room.mealPlan}';
        final current = acc.putIfAbsent(
          key,
          () => _RoomLineAccumulator(
            roomType: room.roomType,
            mealPlan: room.mealPlan,
          ),
        );
        if (room.numberOfRooms > current.qty) {
          current.qty = room.numberOfRooms;
        }
        current.rn += room.totalRn;
        current.total += room.totalSale;
      }
    }

    final lines = acc.values.map((a) {
      final paxValue = partyPax <= 0 ? 1 : partyPax;
      final paxDecimal = Decimal.fromInt(paxValue);
      final rateDouble = (a.total / paxDecimal).toDouble();
      final rate = Decimal.parse(rateDouble.toStringAsFixed(2));
      final rateWithAddOns = rate + additionalPerPax;
      final nights = a.qty > 0 ? (a.rn / a.qty).round() : 0;
      return _RoomLine(
        roomType: a.roomType,
        mealPlan: a.mealPlan,
        qty: a.qty,
        nights: nights,
        pax: paxValue,
        ratePerPax: rateWithAddOns,
        total: a.total,
      );
    }).toList()..sort((a, b) => a.roomType.compareTo(b.roomType));

    return lines;
  }

  static Decimal _additionalPerPax({
    required List<ReservationServiceSummary> transportationServices,
    required List<ReservationServiceSummary> generalServices,
  }) {
    var sum = Decimal.parse('0');

    for (final s in generalServices) {
      final g = s.generalDetails;
      if (g != null) {
        sum += g.salePerItem;
      }
    }

    for (final s in transportationServices) {
      final trips = s.transportationDetails?.trips ?? const [];
      for (final t in trips) {
        sum += t.salePerItem;
      }
    }

    return sum;
  }

  static Decimal _sumMoney(Iterable<Decimal> amounts) {
    return amounts.fold<Decimal>(Decimal.parse('0'), (sum, a) => sum + a);
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String _formatMoney(Decimal amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(double.tryParse(amount.toString()) ?? 0);
  }

  static String _normalizeServiceName(String raw) {
    return raw.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }

  static String _formatLocationCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '-';
    }
    if (trimmed.contains(' ')) {
      return trimmed;
    }
    if (trimmed.length <= 3) {
      return trimmed;
    }
    final prefix = trimmed.substring(0, 3);
    final rest = trimmed.substring(3);
    return '$prefix $rest';
  }

  static String _prettyServiceName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '-';
    }

    final normalized = _normalizeServiceName(trimmed);
    switch (normalized) {
      case 'umrahfullpackage':
        return 'Umrah Full Package';
      case 'arrivalhandling':
        return 'ARRIVAL HANDLING';
      case 'departurehandling':
        return 'DEPARTURE HANDLING';
      case 'medhtlcheckin':
        return 'MED HTL CHECK IN';
      case 'medmazarathandling':
        return 'MED MAZARAT HANDLING';
      case 'medhtlcheckout':
        return 'MED HTL CHECK OUT';
      case 'makhtlcheckin':
        return 'MAK HTL CHECK IN';
      case 'makmazarathandling':
        return 'MAK MAZARAT HANDLING';
      default:
        return trimmed;
    }
  }
}

class _RoomLine {
  const _RoomLine({
    required this.roomType,
    required this.mealPlan,
    required this.qty,
    required this.nights,
    required this.pax,
    required this.ratePerPax,
    required this.total,
  });

  final String roomType;
  final String mealPlan;
  final int qty;
  final int nights;
  final int pax;
  final Decimal ratePerPax;
  final Decimal total;
}

class _RoomLineAccumulator {
  _RoomLineAccumulator({required this.roomType, required this.mealPlan});

  final String roomType;
  final String mealPlan;
  int qty = 0;
  int rn = 0;
  Decimal total = Decimal.parse('0');
}

class _HotelSegmentLine {
  const _HotelSegmentLine({
    required this.reservationNo,
    required this.city,
    required this.hotelName,
    required this.arrivalDate,
    required this.departureDate,
  });

  final String reservationNo;
  final String city;
  final String hotelName;
  final DateTime arrivalDate;
  final DateTime departureDate;
}

const String _cancellationText =
    'Group reservations (5) rooms or more:\n'
    '• When cancelling after confirmation, 50% of the total amount including meals will be charged.\n'
    '• Less than 21 days before arrival, 25% of the total amount including meals will be charged.\n'
    '• Less than 14 days before arrival, 25% of the total amount including meals will be charged.\n'
    '• High season cancellation is subject to 100 % cancellation fee.';
