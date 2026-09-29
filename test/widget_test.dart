import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_dropdown/smart_dropdown.dart';

void main() {
  testWidgets(
    'SmartDropdown displays static options',
    (WidgetTester tester) async {
      final options = [
        const DropdownOption(
          value: 1,
          label: 'India',
        ),
        const DropdownOption(
          value: 2,
          label: 'USA',
        ),
        const DropdownOption(
          value: 3,
          label: 'UK',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartDropdown(
              source: StaticDropdownSource(
                options: options,
              ),
              isMultiSelect: false,
              hint: 'Select Country',
              onChanged: (values) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Select Country'), findsOneWidget);
    },
  );
}