import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_editor/models/document_state.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  group('DocumentState', () {
    late DocumentState documentState;

    setUp(() {
      documentState = DocumentState();
    });

    test('initial state is correct', () {
      expect(documentState.content, '');
      expect(documentState.fileName, 'Untitled.md');
      expect(documentState.filePath, null);
      expect(documentState.isDirty, false);
      expect(documentState.hasFile, false);
      expect(documentState.displayTitle, 'Untitled.md');
    });

    test('updateContent updates content and sets dirty flag', () {
      // Listen to changes
      bool notified = false;
      documentState.addListener(() {
        notified = true;
      });

      // Update content
      documentState.updateContent('# Hello World');

      expect(documentState.content, '# Hello World');
      expect(documentState.isDirty, true);
      expect(documentState.displayTitle, 'Untitled.md*');
      expect(notified, true);
    });

    test('updateContent with same content does not notify', () {
      // Set initial content
      documentState.updateContent('Initial content');

      // Reset notification flag
      bool notified = false;
      documentState.addListener(() {
        notified = true;
      });

      // Update with same content
      documentState.updateContent('Initial content');

      expect(notified, false);
      expect(documentState.isDirty, true); // Still dirty from first update
    });

    test('newFile resets state', () {
      // Set up some state
      documentState.updateContent('Some content');
      
      bool notified = false;
      documentState.addListener(() {
        notified = true;
      });

      // Create new file
      documentState.newFile();

      expect(documentState.content, '');
      expect(documentState.fileName, 'Untitled.md');
      expect(documentState.filePath, null);
      expect(documentState.isDirty, false);
      expect(documentState.hasFile, false);
      expect(documentState.displayTitle, 'Untitled.md');
      expect(notified, true);
    });

    group('File operations', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('markdown_editor_test_');
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('openFile loads content from file', () async {
        // Create a test file
        final testFile = File('${tempDir.path}/test.md');
        const testContent = '# Test File\n\nThis is a test.';
        await testFile.writeAsString(testContent);

        bool notified = false;
        documentState.addListener(() {
          notified = true;
        });

        // Open the file
        await documentState.openFile(testFile.path);

        expect(documentState.content, testContent);
        expect(documentState.fileName, 'test.md');
        expect(documentState.filePath, testFile.path);
        expect(documentState.isDirty, false);
        expect(documentState.hasFile, true);
        expect(notified, true);
      });

      test('openFile throws exception for non-existent file', () async {
        final nonExistentPath = '${tempDir.path}/nonexistent.md';
        
        expect(
          () => documentState.openFile(nonExistentPath),
          throwsA(isA<Exception>()),
        );
      });

      test('saveAsFile creates new file and updates state', () async {
        const testContent = '# New File\n\nThis is new content.';
        documentState.updateContent(testContent);

        final newFilePath = '${tempDir.path}/new_file.md';

        bool notified = false;
        documentState.addListener(() {
          notified = true;
        });

        // Save as new file
        await documentState.saveAsFile(newFilePath);

        expect(documentState.filePath, newFilePath);
        expect(documentState.fileName, 'new_file.md');
        expect(documentState.isDirty, false);
        expect(documentState.hasFile, true);
        expect(notified, true);

        // Verify file was created with correct content
        final savedFile = File(newFilePath);
        expect(await savedFile.exists(), true);
        expect(await savedFile.readAsString(), testContent);
      });

      test('saveFile saves to existing file path', () async {
        // Create initial file
        final testFile = File('${tempDir.path}/existing.md');
        const initialContent = '# Initial Content';
        await testFile.writeAsString(initialContent);

        // Open the file
        await documentState.openFile(testFile.path);

        // Modify content
        const newContent = '# Modified Content\n\nThis was changed.';
        documentState.updateContent(newContent);
        expect(documentState.isDirty, true);

        bool notified = false;
        documentState.addListener(() {
          notified = true;
        });

        // Save the file
        await documentState.saveFile();

        expect(documentState.isDirty, false);
        expect(notified, true);

        // Verify file content was updated
        final savedContent = await testFile.readAsString();
        expect(savedContent, newContent);
      });

      test('saveFile throws exception when no file path is set', () async {
        documentState.updateContent('Some content');
        
        expect(
          () => documentState.saveFile(),
          throwsA(isA<Exception>()),
        );
      });
    });

    test('displayTitle shows asterisk when dirty', () {
      expect(documentState.displayTitle, 'Untitled.md');

      documentState.updateContent('Modified');
      expect(documentState.displayTitle, 'Untitled.md*');
    });
  });
}
