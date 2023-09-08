// 🎯 Dart imports:
import 'dart:io';

/// Sort the imports
/// Returns the sorted file as a string at
/// index 0 and the number of sorted imports
/// at index 1
ImportSortData sortImports(
  List<String> lines,
  String package_name,
  bool exitIfChanged, {
  String? filePath,
}) {
  final beforeImportLines = <String>[];
  final afterImportLines = <String>[];

  final imports = <String>[];

  bool noImports() => imports.isEmpty;

  var isMultiLineString = false;

  for (var i = 0; i < lines.length; i++) {
    // Check if line is in multiline string
    if (_timesContained(lines[i], "'''") == 1 || _timesContained(lines[i], '"""') == 1) {
      isMultiLineString = !isMultiLineString;
    }

    // If line is an import line
    if (lines[i].startsWith('import ') && lines[i].endsWith(';') && !isMultiLineString) {
      imports.add(lines[i]);
    } else if (noImports()) {
      beforeImportLines.add(lines[i]);
    } else {
      afterImportLines.add(lines[i]);
    }
  }

  // If no imports return original string of lines
  if (noImports()) {
    var joinedLines = lines.join('\n');
    if (joinedLines.endsWith('\n') && !joinedLines.endsWith('\n\n')) {
      joinedLines += '\n';
    } else if (!joinedLines.endsWith('\n')) {
      joinedLines += '\n';
    }
    return ImportSortData(joinedLines, false);
  }

  // Remove spaces
  if (beforeImportLines.isNotEmpty) {
    if (beforeImportLines.last.trim() == '') {
      beforeImportLines.removeLast();
    }
  }

  final sortedLines = <String>[...beforeImportLines];

  // Adding content conditionally
  if (beforeImportLines.isNotEmpty) {
    sortedLines.add('');
  }
  if (imports.isNotEmpty) {
    imports.sort();
    sortedLines.addAll(imports);
  }

  sortedLines.add('');

  var addedCode = false;
  for (var j = 0; j < afterImportLines.length; j++) {
    if (afterImportLines[j] != '') {
      sortedLines.add(afterImportLines[j]);
      addedCode = true;
    }
    if (addedCode && afterImportLines[j] == '') {
      sortedLines.add(afterImportLines[j]);
    }
  }
  sortedLines.add('');

  final sortedFile = sortedLines.join('\n');
  final original = lines.join('\n') + '\n';
  if (exitIfChanged && original != sortedFile) {
    if (filePath != null) {
      stdout.writeln('\n┗━━🚨 File ${filePath} does not have its imports sorted.');
    }
    exit(1);
  }
  if (original == sortedFile) {
    return ImportSortData(original, false);
  }

  return ImportSortData(sortedFile, true);
}

/// Get the number of times a string contains another
/// string
int _timesContained(String string, String looking) => string.split(looking).length - 1;

/// Data to return from a sort
class ImportSortData {
  final String sortedFile;
  final bool updated;

  const ImportSortData(this.sortedFile, this.updated);
}
