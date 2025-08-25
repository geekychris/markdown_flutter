import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/document_state.dart';
import 'screens/markdown_editor_screen.dart';

void main() {
  runApp(const MarkdownEditorApp());
}

class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DocumentState(),
      child: MaterialApp(
        title: 'Markdown Editor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Text',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Text',
        ),
        themeMode: ThemeMode.system,
        home: const MarkdownEditorScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
