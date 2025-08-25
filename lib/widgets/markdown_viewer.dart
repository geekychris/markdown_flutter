import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/document_state.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownViewer extends StatelessWidget {
  const MarkdownViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentState>(
      builder: (context, documentState, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: documentState.content.isEmpty
              ? _buildEmptyState(context)
              : Markdown(
                  data: documentState.content,
                  selectable: true,
                  styleSheet: _buildMarkdownStyleSheet(context),
                  extensionSet: md.ExtensionSet.gitHubFlavored,
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      // Handle link taps - could open in browser
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Link tapped: $href')),
                      );
                    }
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.preview,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Markdown Preview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start typing in the editor to see your markdown rendered here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return MarkdownStyleSheet(
      a: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      p: textTheme.bodyMedium?.copyWith(
        height: 1.6,
        fontSize: 16,
      ),
      h1: textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      h2: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      h3: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      h4: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      h5: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      h6: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      code: TextStyle(
        fontFamily: 'Monaco',
        fontSize: 14,
        backgroundColor: theme.colorScheme.surfaceContainer,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      codeblockPadding: const EdgeInsets.all(16),
      blockquote: textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      listBullet: textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
      listIndent: 24,
      tableHead: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      tableBody: textTheme.bodyMedium,
      tableBorder: TableBorder.all(
        color: theme.colorScheme.outline.withOpacity(0.3),
        width: 1,
      ),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.all(8),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
    );
  }
}
