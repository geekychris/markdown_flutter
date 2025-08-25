import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_state.dart';

class FileService {
  static Future<void> openFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final documentState = context.read<DocumentState>();
        await documentState.openFile(result.files.single.path!);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opened ${documentState.fileName}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  static Future<void> saveFile(BuildContext context) async {
    final documentState = context.read<DocumentState>();
    
    try {
      if (documentState.hasFile) {
        await documentState.saveFile();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved ${documentState.fileName}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await saveAsFile(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  static Future<void> saveAsFile(BuildContext context) async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save markdown file',
        fileName: 'document.md',
      );

      if (path != null) {
        final documentState = context.read<DocumentState>();
        await documentState.saveAsFile(path);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved as ${documentState.fileName}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  static void newFile(BuildContext context) {
    final documentState = context.read<DocumentState>();
    
    // Check if current file has unsaved changes
    if (documentState.isDirty) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: Text(
            'You have unsaved changes in ${documentState.fileName}. '
            'Do you want to save them before creating a new file?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Don\'t Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ).then((shouldSave) async {
        if (shouldSave == null) return; // Cancelled
        
        if (shouldSave) {
          try {
            await saveFile(context);
          } catch (e) {
            return; // Don't create new file if save failed
          }
        }
        
        documentState.newFile();
      });
    } else {
      documentState.newFile();
    }
  }
}
