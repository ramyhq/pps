import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/widgets/custom_form_fields.dart';
import 'package:pps/features/reservations/ui/screens/create_agent_reservation_screen.dart';

void main() {
  testWidgets('Add button adds room row and updates pax summary', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final exceptionText = details.exceptionAsString();
      if (exceptionText.contains('A RenderFlex overflowed by')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateAgentReservationScreen(reservationId: 'r1'),
        ),
      ),
    );

    final roomDetailsHeader = find.text('Room details');
    final roomDetailsCard = find
        .ancestor(of: roomDetailsHeader, matching: find.byType(Card))
        .first;
    final noRoomsInput = find.descendant(
      of: roomDetailsCard,
      matching: find.byType(TextField),
    );
    await tester.enterText(noRoomsInput.first, '2');
    await tester.pumpAndSettle();

    final roomTypeDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Room type',
    );
    final roomTypeTapTarget = find.descendant(
      of: roomTypeDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(roomTypeTapTarget.first);
    await tester.tap(roomTypeTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Double').first);
    await tester.pumpAndSettle();

    final mealPlanDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Meal plan',
    );
    final mealPlanTapTarget = find.descendant(
      of: mealPlanDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(mealPlanTapTarget.first);
    await tester.tap(mealPlanTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BB').first);
    await tester.pumpAndSettle();

    final applyButton = find.text('Apply');
    await tester.ensureVisible(applyButton);
    final applyRow = find
        .ancestor(of: applyButton, matching: find.byType(Row))
        .first;
    final applyInputs = find.descendant(
      of: applyRow,
      matching: find.byType(TextField),
    );
    await tester.enterText(applyInputs.first, '200');
    await tester.pumpAndSettle();
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Double'), findsAtLeastNWidgets(2));
    expect(find.text('BB'), findsAtLeastNWidgets(2));
    final rnCheckIcon = find.descendant(
      of: roomDetailsCard,
      matching: find.byIcon(Icons.check_circle),
    );
    expect(rnCheckIcon, findsAtLeastNWidgets(1));
    expect(find.text('4'), findsAtLeastNWidgets(1));
  });

  testWidgets('Edit restores daily rates and apply inputs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final exceptionText = details.exceptionAsString();
      if (exceptionText.contains('A RenderFlex overflowed by')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateAgentReservationScreen(reservationId: 'r1'),
        ),
      ),
    );

    final roomDetailsHeader = find.text('Room details');
    final roomDetailsCard = find
        .ancestor(of: roomDetailsHeader, matching: find.byType(Card))
        .first;
    final noRoomsInput = find.descendant(
      of: roomDetailsCard,
      matching: find.byType(TextField),
    );
    await tester.enterText(noRoomsInput.first, '2');
    await tester.pumpAndSettle();

    final roomTypeDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Room type',
    );
    final roomTypeTapTarget = find.descendant(
      of: roomTypeDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(roomTypeTapTarget.first);
    await tester.tap(roomTypeTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Double').first);
    await tester.pumpAndSettle();

    final mealPlanDropdown = find.byWidgetPredicate(
      (widget) => widget is CustomDropdown && widget.label == 'Meal plan',
    );
    final mealPlanTapTarget = find.descendant(
      of: mealPlanDropdown,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(mealPlanTapTarget.first);
    await tester.tap(mealPlanTapTarget.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BB').first);
    await tester.pumpAndSettle();

    final applyButton = find.text('Apply');
    await tester.ensureVisible(applyButton);
    final applyRow = find
        .ancestor(of: applyButton, matching: find.byType(Row))
        .first;
    final applyInputs = find.descendant(
      of: applyRow,
      matching: find.byType(TextField),
    );
    await tester.enterText(applyInputs.first, '200');
    await tester.pumpAndSettle();
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final editIcon = find.byIcon(Icons.edit_outlined).first;
    await tester.ensureVisible(editIcon);
    await tester.tap(editIcon);
    await tester.pumpAndSettle();

    final refreshedApplyInputs = find.descendant(
      of: applyRow,
      matching: find.byType(TextField),
    );
    final firstApplyTextField = tester.widget<TextField>(
      refreshedApplyInputs.first,
    );
    expect(firstApplyTextField.controller?.text, '200');
    expect(find.text('200'), findsAtLeastNWidgets(1));
  });
}
