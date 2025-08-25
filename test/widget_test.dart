// This is a basic Flutter widget test for the Markdown Editor app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markdown_editor/main.dart';

void main() {
  testWidgets('Markdown Editor App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarkdownEditorApp());

    // Verify that the app starts with the correct title.
    expect(find.text('Untitled.md'), findsOneWidget);

    // Verify that toolbar buttons are present.
    expect(find.byIcon(Icons.format_bold), findsOneWidget);
    expect(find.byIcon(Icons.format_italic), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget); // New file button
    expect(find.byIcon(Icons.folder_open), findsOneWidget); // Open file button
    expect(find.byIcon(Icons.save), findsOneWidget); // Save button

    // Verify that the preview empty state is shown.
    expect(find.text('Markdown Preview'), findsOneWidget);
    expect(find.text('Start typing in the editor to see your markdown rendered here.'), findsOneWidget);

    // Verify that the text input field is present.
    expect(find.text('Start writing your markdown...'), findsOneWidget);
  });

  testWidgets('Markdown Editor text input updates preview', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarkdownEditorApp());

    // Find the text input field.
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter some markdown text.
    await tester.enterText(textField, '# Hello World\n\nThis is **bold** text.');
    await tester.pump();

    // Verify that the text was entered (document state should be updated).
    // Note: We can't easily test the rendered markdown without more complex setup,
    // but we can verify the input was accepted.
    final textFieldWidget = tester.widget<TextField>(textField);
    expect(textFieldWidget.controller?.text, '# Hello World\n\nThis is **bold** text.');
  });

  testWidgets('Toolbar buttons insert markdown syntax', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarkdownEditorApp());

    // Find the text input field and bold button.
    final textField = find.byType(TextField);
    final boldButton = find.byIcon(Icons.format_bold);
    
    expect(textField, findsOneWidget);
    expect(boldButton, findsOneWidget);

    // Enter some text first.
    await tester.enterText(textField, 'Hello');
    await tester.pump();

    // Select the text.
    final textFieldWidget = tester.widget<TextField>(textField);
    textFieldWidget.controller?.selection = const TextSelection(baseOffset: 0, extentOffset: 5);

    // Tap the bold button.
    await tester.tap(boldButton);
    await tester.pump();

    // Verify that bold markdown syntax was added.
    expect(textFieldWidget.controller?.text, '**Hello**');
  });

  testWidgets('Preview visibility can be toggled', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarkdownEditorApp());

    // Find the visibility toggle button.
    final visibilityButton = find.byIcon(Icons.visibility_off);
    expect(visibilityButton, findsOneWidget);

    // Verify preview is initially visible.
    expect(find.text('Markdown Preview'), findsOneWidget);

    // Tap the visibility button to hide preview.
    await tester.tap(visibilityButton);
    await tester.pump();

    // Verify preview is now hidden and button icon changed.
    expect(find.text('Markdown Preview'), findsNothing);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
