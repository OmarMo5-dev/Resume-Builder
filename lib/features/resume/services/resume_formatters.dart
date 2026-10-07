/// Pure, strongly-typed helpers shared by the PDF generator and the in-app
/// preview. Nothing here uses `dynamic`.
class ResumeText {
  const ResumeText._();

  /// Trims [value] and replaces typographic punctuation that standard PDF
  /// fonts cannot render with plain ASCII equivalents.
  static String clean(String? value) {
    if (value == null) return '';
    var out = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    const replacements = <String, String>{
      '\u2013': '-',
      '\u2014': '-',
      '\u2018': "'",
      '\u2019': "'",
      '\u201C': '"',
      '\u201D': '"',
      '\u2026': '...',
      '\u2022': '-',
      '\u00A0': ' ',
    };
    replacements.forEach((from, to) {
      out = out.replaceAll(from, to);
    });
    return out.trim();
  }

  /// Splits multi-line text into trimmed, non-empty lines.
  static List<String> lines(String? value) {
    final result = <String>[];
    for (final raw in clean(value).split('\n')) {
      final line = raw.trim();
      if (line.isNotEmpty) result.add(line);
    }
    return result;
  }

  /// Cleans every entry and drops the empty ones.
  static List<String> cleanList(Iterable<String> values) {
    final result = <String>[];
    for (final raw in values) {
      final item = clean(raw);
      if (item.isNotEmpty) result.add(item);
    }
    return result;
  }

  static String dateRange(String? start, String? end, bool isCurrent) {
    final s = clean(start);
    final e = clean(end);
    if (isCurrent) return s.isEmpty ? 'Present' : '$s - Present';
    if (s.isEmpty) return e;
    if (e.isEmpty) return s;
    return '$s - $e';
  }

  static String joinNonEmpty(List<String> parts, String separator) {
    final kept = <String>[];
    for (final part in parts) {
      final p = clean(part);
      if (p.isNotEmpty) kept.add(p);
    }
    return kept.join(separator);
  }
}

class ResumeLinks {
  const ResumeLinks._();

  static final RegExp _scheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:');
  static final RegExp _emailLike = RegExp(r'^[^\s@/]+@[^\s@/]+\.[^\s@/]+$');

  /// Returns a safe absolute URL string, or null when [raw] is empty.
  ///
  /// github.com/x        -> https://github.com/x
  /// user@example.com    -> mailto:user@example.com
  /// mailto:/tel:/https: -> unchanged
  static String? normalize(String? raw) {
    final v = ResumeText.clean(raw);
    if (v.isEmpty) return null;
    final lower = v.toLowerCase();
    if (lower.startsWith('mailto:') || lower.startsWith('tel:')) return v;
    if (lower.startsWith('http://') || lower.startsWith('https://')) return v;
    if (_emailLike.hasMatch(v)) return 'mailto:$v';
    if (_scheme.hasMatch(v) && v.contains('://')) return v;
    return 'https://$v';
  }

  static String? phone(String? raw) {
    final v = ResumeText.clean(raw);
    if (v.isEmpty) return null;
    final buffer = StringBuffer();
    for (var i = 0; i < v.length; i++) {
      final ch = v[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      if (isDigit || (ch == '+' && buffer.isEmpty)) buffer.write(ch);
    }
    final digits = buffer.toString();
    return digits.isEmpty ? null : 'tel:$digits';
  }

  /// Human readable form of a URL (no scheme, no trailing slash).
  static String display(String? raw) {
    var v = ResumeText.clean(raw);
    final lower = v.toLowerCase();
    if (lower.startsWith('mailto:')) v = v.substring(7);
    if (lower.startsWith('tel:')) v = v.substring(4);
    v = v.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }

  static Uri? toUri(String? raw) {
    final normalized = normalize(raw);
    return normalized == null ? null : Uri.tryParse(normalized);
  }
}
