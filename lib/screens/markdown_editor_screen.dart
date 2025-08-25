import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/document_state.dart';
import '../widgets/markdown_editor.dart';
import '../widgets/markdown_viewer.dart';
import '../services/file_service.dart';

class MarkdownEditorScreen extends StatefulWidget {
  const MarkdownEditorScreen({super.key});

  @override
  State<MarkdownEditorScreen> createState() => _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends State<MarkdownEditorScreen> {
  bool _isPreviewVisible = true;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentState>(
      builder: (context, documentState, child) {
        return Scaffold(
          appBar: _buildAppBar(documentState),
          body: _isPreviewVisible ? _buildSplitView() : const MarkdownEditor(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(DocumentState documentState) {
    return AppBar(
      title: Text(
        documentState.displayTitle,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'New File (Cmd+N)',
          onPressed: () => FileService.newFile(context),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Open File (Cmd+O)',
          onPressed: () => FileService.openFile(context),
        ),
        IconButton(
          icon: const Icon(Icons.save),
          tooltip: 'Save File (Cmd+S)',
          onPressed: () => FileService.saveFile(context),
        ),
        IconButton(
          icon: const Icon(Icons.save_as),
          tooltip: 'Save As (Cmd+Shift+S)',
          onPressed: () => FileService.saveAsFile(context),
        ),
        const VerticalDivider(),
        IconButton(
          icon: Icon(_isPreviewVisible ? Icons.visibility_off : Icons.visibility),
          tooltip: _isPreviewVisible ? 'Hide Preview' : 'Show Preview',
          onPressed: () {
            setState(() {
              _isPreviewVisible = !_isPreviewVisible;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSplitView() {
    return Row(
      children: [
        // Editor panel
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: const MarkdownEditor(),
          ),
        ),
        // Resizable divider
        Container(
          width: 4,
          color: Theme.of(context).colorScheme.surface,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onPanUpdate: (details) {
                // TODO: Implement resizable panels if needed
              },
            ),
          ),
        ),
        // Preview panel
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: const MarkdownViewer(),
          ),
        ),
      ],
    );
  }
}

class _KeyboardShortcuts extends StatelessWidget {
  final Widget child;

  const _KeyboardShortcuts({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN):
            const _NewFileIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyO):
            const _OpenFileIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
            const _SaveFileIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyS):
            const _SaveAsFileIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _NewFileIntent: _NewFileAction(),
          _OpenFileIntent: _OpenFileAction(),
          _SaveFileIntent: _SaveFileAction(),
          _SaveAsFileIntent: _SaveAsFileAction(),
        },
        child: child,
      ),
    );
  }
}

// Intents for keyboard shortcuts
class _NewFileIntent extends Intent {
  const _NewFileIntent();
}

class _OpenFileIntent extends Intent {
  const _OpenFileIntent();
}

class _SaveFileIntent extends Intent {
  const _SaveFileIntent();
}

class _SaveAsFileIntent extends Intent {
  const _SaveAsFileIntent();
}

// Actions for keyboard shortcuts
class _NewFileAction extends Action<_NewFileIntent> {
  @override
  Object? invoke(_NewFileIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      FileService.newFile(context);
    }
    return null;
  }
}

class _OpenFileAction extends Action<_OpenFileIntent> {
  @override
  Object? invoke(_OpenFileIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      FileService.openFile(context);
    }
    return null;
  }
}

class _SaveFileAction extends Action<_SaveFileIntent> {
  @override
  Object? invoke(_SaveFileIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      FileService.saveFile(context);
    }
    return null;
  }
}

class _SaveAsFileAction extends Action<_SaveAsFileIntent> {
  @override
  Object? invoke(_SaveAsFileIntent intent) {
    final context = primaryFocus?.context;
    if (context != null) {
      FileService.saveAsFile(context);
    }
    return null;
  }
}
