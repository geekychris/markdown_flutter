import 'package:flutter/foundation.dart';
import 'dart:io';

class DocumentState extends ChangeNotifier {
  String _content = '';
  String? _filePath;
  bool _isDirty = false;
  String _fileName = 'Untitled.md';

  String get content => _content;
  String? get filePath => _filePath;
  bool get isDirty => _isDirty;
  String get fileName => _fileName;
  
  bool get hasFile => _filePath != null;

  void updateContent(String newContent) {
    if (_content != newContent) {
      _content = newContent;
      _isDirty = true;
      notifyListeners();
    }
  }

  Future<void> openFile(String path) async {
    try {
      final file = File(path);
      final content = await file.readAsString();
      
      _content = content;
      _filePath = path;
      _fileName = file.path.split('/').last;
      _isDirty = false;
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to open file: $e');
    }
  }

  Future<void> saveFile() async {
    if (_filePath == null) {
      throw Exception('No file path set');
    }
    
    try {
      final file = File(_filePath!);
      await file.writeAsString(_content);
      _isDirty = false;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  Future<void> saveAsFile(String path) async {
    try {
      final file = File(path);
      await file.writeAsString(_content);
      
      _filePath = path;
      _fileName = file.path.split('/').last;
      _isDirty = false;
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  void newFile() {
    _content = '';
    _filePath = null;
    _fileName = 'Untitled.md';
    _isDirty = false;
    notifyListeners();
  }

  String get displayTitle {
    return _isDirty ? '$_fileName*' : _fileName;
  }
}
