import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/document_state.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({super.key});

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize with current content
    final documentState = context.read<DocumentState>();
    if (_controller.text != documentState.content) {
      _controller.text = documentState.content;
    }
    
    // Listen to content changes if not already listening
    if (!_controller.hasListeners) {
      _controller.addListener(() {
        documentState.updateContent(_controller.text);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insertMarkdown(String markdown) {
    final selection = _controller.selection;
    final text = _controller.text;
    
    if (selection.isValid) {
      final selectedText = selection.textInside(text);
      final newText = markdown.replaceAll('{selection}', selectedText);
      
      _controller.text = text.replaceRange(
        selection.start,
        selection.end,
        newText,
      );
      
      // Update cursor position
      final newCursorPos = selection.start + newText.length;
      _controller.selection = TextSelection.collapsed(offset: newCursorPos);
    }
    
    _focusNode.requestFocus();
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: Wrap(
        spacing: 4.0,
        children: [
          _ToolbarButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            onPressed: () => _insertMarkdown('**{selection}**'),
          ),
          _ToolbarButton(
            icon: Icons.format_italic,
            tooltip: 'Italic',
            onPressed: () => _insertMarkdown('*{selection}*'),
          ),
          _ToolbarButton(
            icon: Icons.format_strikethrough,
            tooltip: 'Strikethrough',
            onPressed: () => _insertMarkdown('~~{selection}~~'),
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            icon: Icons.title,
            tooltip: 'Heading 1',
            onPressed: () => _insertMarkdown('# {selection}'),
          ),
          _ToolbarButton(
            icon: Icons.format_size,
            tooltip: 'Heading 2',
            onPressed: () => _insertMarkdown('## {selection}'),
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bulleted List',
            onPressed: () => _insertMarkdown('- {selection}'),
          ),
          _ToolbarButton(
            icon: Icons.format_list_numbered,
            tooltip: 'Numbered List',
            onPressed: () => _insertMarkdown('1. {selection}'),
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            icon: Icons.link,
            tooltip: 'Link',
            onPressed: () => _insertMarkdown('[{selection}](url)'),
          ),
          _ToolbarButton(
            icon: Icons.image,
            tooltip: 'Image',
            onPressed: () => _insertMarkdown('![{selection}](image-url)'),
          ),
          _ToolbarButton(
            icon: Icons.code,
            tooltip: 'Code',
            onPressed: () => _insertMarkdown('`{selection}`'),
          ),
          _ToolbarButton(
            icon: Icons.format_quote,
            tooltip: 'Quote',
            onPressed: () => _insertMarkdown('> {selection}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentState>(
      builder: (context, documentState, child) {
        // Update controller if content changed externally
        if (_controller.text != documentState.content) {
          _controller.text = documentState.content;
        }
        
        return Column(
          children: [
            _buildToolbar(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontFamily: 'Monaco',
                    fontSize: 14,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start writing your markdown...',
                  ),
                  onChanged: (value) {
                    documentState.updateContent(value);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}
