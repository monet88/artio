import 'package:artio/features/template_engine/domain/entities/input_field_model.dart';
import 'package:artio/features/template_engine/presentation/widgets/input_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/helpers/pump_app.dart';

void main() {
  group('InputFieldBuilder', () {
    testWidgets('renders text input field', (tester) async {
      const field = InputFieldModel(
        name: 'prompt',
        label: 'Prompt',
        type: 'text',
        placeholder: 'Enter your prompt...',
        required: true,
      );

      await tester.pumpApp(
        Scaffold(
          body: InputFieldBuilder(
            field: field,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Prompt'), findsOneWidget);
      expect(find.text('Enter your prompt...'), findsOneWidget);
    });

    testWidgets('calls onChanged for text input', (tester) async {
      const field = InputFieldModel(
        name: 'prompt',
        label: 'Prompt',
        type: 'text',
      );

      String? capturedValue;

      await tester.pumpApp(
        Scaffold(
          body: InputFieldBuilder(
            field: field,
            onChanged: (value) => capturedValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello');
      expect(capturedValue, 'Hello');
    });

    testWidgets('renders dropdown field for select type', (tester) async {
      const field = InputFieldModel(
        name: 'style',
        label: 'Style',
        type: 'select',
        options: ['Option A', 'Option B'],
      );

      await tester.pumpApp(
        Scaffold(
          body: InputFieldBuilder(
            field: field,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Style'), findsOneWidget);
    });

    testWidgets('dropdown calls onChanged when option selected',
        (tester) async {
      const field = InputFieldModel(
        name: 'style',
        label: 'Style',
        type: 'select',
        options: ['Option A', 'Option B'],
      );

      String? capturedValue;

      await tester.pumpApp(
        Scaffold(
          body: InputFieldBuilder(
            field: field,
            onChanged: (value) => capturedValue = value,
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select an option
      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();

      expect(capturedValue, 'Option B');
    });

    testWidgets('renders text field for unknown types (fallback)',
        (tester) async {
      const field = InputFieldModel(
        name: 'reference',
        label: 'Reference Image',
        type: 'image', // Unknown type, falls back to text
      );

      await tester.pumpApp(
        Scaffold(
          body: InputFieldBuilder(
            field: field,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Reference Image'), findsOneWidget);
    });

    testWidgets('required field validation returns error', (tester) async {
      final formKey = GlobalKey<FormState>();
      const field = InputFieldModel(
        name: 'prompt',
        label: 'Prompt',
        type: 'text',
        required: true,
      );

      await tester.pumpApp(
        Scaffold(
          body: Form(
            key: formKey,
            child: InputFieldBuilder(
              field: field,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final isValid = formKey.currentState!.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('shows default value if provided', (tester) async {
      const field = InputFieldModel(
        name: 'prompt',
        label: 'Prompt',
        type: 'text',
        defaultValue: 'Default text',
      );

      await tester.pumpApp(
        Scaffold(
          body: InputFieldBuilder(
            field: field,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Default text'), findsOneWidget);
    });
  });
}
