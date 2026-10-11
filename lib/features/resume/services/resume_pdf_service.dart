import 'dart:typed_data';

import 'package:business_os/features/resume/presentation/widgets/resume_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/entities/course.dart';
import '../domain/entities/education.dart';
import '../domain/entities/experience.dart';
import '../domain/entities/language.dart';
import '../domain/entities/project.dart';
import '../domain/entities/resume.dart';
import '../domain/entities/skill_group.dart';
import 'resume_formatters.dart';

/// Thrown when a PDF cannot be produced. [message] is safe to show to users.
class ResumePdfException implements Exception {
  final String message;
  final Object? cause;

  const ResumePdfException(this.message, [this.cause]);

  @override
  String toString() => message;
}

class ResumePdfService {
  const ResumePdfService._();

  static Future<Uint8List> build(Resume resume) async {
    try {
      final style = await _Style.load(resume.templateId);
      final name = ResumeText.clean(resume.personalInfo.fullName);
      final document = pw.Document(
        title: ResumeText.clean(resume.title).isEmpty
            ? 'Resume'
            : ResumeText.clean(resume.title),
        author: name,
        creator: 'Business OS',
      );
      final body = _ResumeBody(resume, style).build();

      document.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.fromLTRB(
              style.margin,
              style.margin * 0.9,
              style.margin,
              style.margin * 0.8,
            ),
            theme: style.theme,
          ),
          header: (pw.Context context) {
            if (context.pageNumber <= 1 || name.isEmpty) return pw.SizedBox();
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 6),
              margin: const pw.EdgeInsets.only(bottom: 10),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: style.rule, width: 0.5),
                ),
              ),
              child: pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: style.metaSize + 1,
                  color: style.muted,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          },
          footer: (pw.Context context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 7, color: style.muted),
            ),
          ),
          build: (pw.Context context) => body,
        ),
      );
      return await document.save();
    } catch (e, st) {
      debugPrint('PDF generation failed: $e\n$st');
      throw ResumePdfException('PDF generation failed: $e', e);
    }
  }

  /// Generates the PDF, writes it to a temporary file and opens the native
  /// share sheet (handled by the `printing` package).
  static Future<void> share(Resume resume) async {
    final bytes = await build(resume);
    try {
      final ok = await Printing.sharePdf(
        bytes: bytes,
        filename: fileName(resume),
      );
      if (!ok) debugPrint('Share sheet was dismissed or unavailable.');
    } catch (e, st) {
      debugPrint('PDF share failed: $e\n$st');
      throw ResumePdfException('PDF sharing failed: $e', e);
    }
  }

  /// Opens the system print / save-as-PDF dialog with the generated document.
  static Future<void> export(Resume resume) async {
    final bytes = await build(resume);
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: fileName(resume),
      );
    } catch (e, st) {
      debugPrint('PDF export failed: $e\n$st');
      throw ResumePdfException('PDF export failed: $e', e);
    }
  }

  static String fileName(Resume resume) {
    final title = ResumeText.clean(resume.title);
    final base = title.isEmpty ? 'resume' : title;
    final safe = base.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return '${safe.isEmpty ? 'resume' : safe}.pdf';
  }
}

// -----------------------------------------------------------------------------
// Templates
// -----------------------------------------------------------------------------

enum _HeaderKind { centered, split, plain }

enum _SectionKind { ruled, accentBar, quiet }

class _Style {
  final pw.ThemeData theme;
  final _HeaderKind header;
  final _SectionKind section;
  final PdfColor ink;
  final PdfColor muted;
  final PdfColor accent;
  final PdfColor link;
  final PdfColor rule;
  final double margin;
  final double nameSize;
  final double titleSize;
  final double sectionSize;
  final double headingSize;
  final double bodySize;
  final double metaSize;
  final double sectionGap;
  final double entryGap;

  const _Style({
    required this.theme,
    required this.header,
    required this.section,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.link,
    required this.rule,
    required this.margin,
    required this.nameSize,
    required this.titleSize,
    required this.sectionSize,
    required this.headingSize,
    required this.bodySize,
    required this.metaSize,
    required this.sectionGap,
    required this.entryGap,
  });

  static const PdfColor _link = PdfColor.fromInt(0xFF0B5CAD);

  static Future<_Style> load(String templateId) async {
    switch (templateId) {
      case 'modern_01':
        return _Style(
          theme: await _rubikTheme(),
          header: _HeaderKind.split,
          section: _SectionKind.accentBar,
          ink: const PdfColor.fromInt(0xFF1B1B1F),
          muted: const PdfColor.fromInt(0xFF5B6270),
          accent: const PdfColor.fromInt(0xFF1F4E79),
          link: _link,
          rule: const PdfColor.fromInt(0xFFC9D1DC),
          margin: 40,
          nameSize: 24,
          titleSize: 11.5,
          sectionSize: 10.5,
          headingSize: 10,
          bodySize: 9,
          metaSize: 8.5,
          sectionGap: 16,
          entryGap: 9,
        );
      case 'minimal_01':
        return _Style(
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
            italic: pw.Font.helveticaOblique(),
            boldItalic: pw.Font.helveticaBoldOblique(),
          ),
          header: _HeaderKind.plain,
          section: _SectionKind.quiet,
          ink: PdfColors.grey900,
          muted: PdfColors.grey700,
          accent: PdfColors.grey800,
          link: _link,
          rule: PdfColors.grey400,
          margin: 50,
          nameSize: 20,
          titleSize: 10.5,
          sectionSize: 9,
          headingSize: 9.5,
          bodySize: 8.8,
          metaSize: 8.3,
          sectionGap: 18,
          entryGap: 10,
        );
      default:
        return _Style(
          theme: pw.ThemeData.withFont(
            base: pw.Font.times(),
            bold: pw.Font.timesBold(),
            italic: pw.Font.timesItalic(),
            boldItalic: pw.Font.timesBoldItalic(),
          ),
          header: _HeaderKind.centered,
          section: _SectionKind.ruled,
          ink: PdfColors.black,
          muted: PdfColors.grey800,
          accent: PdfColors.black,
          link: _link,
          rule: PdfColors.grey700,
          margin: 44,
          nameSize: 24,
          titleSize: 12,
          sectionSize: 11,
          headingSize: 10.5,
          bodySize: 10,
          metaSize: 9.5,
          sectionGap: 14,
          entryGap: 8,
        );
    }
  }

  /// Rubik ships with the app (assets/fonts). Falls back to Helvetica if the
  /// asset cannot be loaded, so PDF generation never depends on it.
  static Future<pw.ThemeData> _rubikTheme() async {
    try {
      final regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Rubik-Regular.ttf'),
      );
      final bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Rubik-Bold.ttf'),
      );
      return pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: regular,
        boldItalic: bold,
      );
    } catch (e) {
      debugPrint('Rubik font unavailable for PDF, using Helvetica: $e');
      return pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
        boldItalic: pw.Font.helveticaBoldOblique(),
      );
    }
  }
}

enum _IconKind { email, phone, location, website, linkedin, github }

class _Contact {
  final _IconKind icon;
  final String label;
  final String? destination;

  const _Contact(this.icon, this.label, this.destination);
}

// -----------------------------------------------------------------------------
// Body builder
// -----------------------------------------------------------------------------

class _ResumeBody {
  final Resume resume;
  final _Style s;

  const _ResumeBody(this.resume, this.s);

  List<pw.Widget> build() {
    final out = <pw.Widget>[_header()];

    final summary = ResumeText.clean(resume.summary);
    if (summary.isNotEmpty) {
      final paragraphs = <pw.Widget>[];
      for (final line in ResumeText.lines(summary)) {
        paragraphs.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(line, style: _body()),
          ),
        );
      }
      out.addAll(_section('PROFESSIONAL SUMMARY', paragraphs));
    }

    final experience = <pw.Widget>[];
    for (final e in resume.experience) {
      experience.addAll(_experience(e));
    }
    out.addAll(_section('PROFESSIONAL EXPERIENCE', experience));

    final projects = <pw.Widget>[];
    for (final e in resume.projects) {
      projects.addAll(_project(e));
    }
    out.addAll(_section('PROJECTS', projects));

    final skills = <pw.Widget>[];
    for (final e in resume.skills) {
      skills.addAll(_skillGroup(e));
    }
    out.addAll(_section('SKILLS', skills));

    final courses = <pw.Widget>[];
    for (final e in resume.courses) {
      courses.addAll(_course(e));
    }
    out.addAll(_section('COURSES & CERTIFICATIONS', courses));

    final education = <pw.Widget>[];
    for (final e in resume.education) {
      education.addAll(_education(e));
    }
    out.addAll(_section('EDUCATION', education));

    final languages = <pw.Widget>[];
    for (final e in resume.languages) {
      languages.addAll(_language(e));
    }
    out.addAll(_section('LANGUAGES', languages));

    return out;
  }

  // ---- text styles ----------------------------------------------------------

  pw.TextStyle _body() =>
      pw.TextStyle(fontSize: s.bodySize, color: s.ink, lineSpacing: 2);

  pw.TextStyle _meta() => pw.TextStyle(fontSize: s.metaSize, color: s.muted);

  pw.TextStyle _heading() => pw.TextStyle(
    fontSize: s.headingSize,
    color: s.ink,
    fontWeight: pw.FontWeight.bold,
  );

  pw.TextStyle _linkStyle(double size) => pw.TextStyle(
    fontSize: size,
    color: s.link,
    decoration: pw.TextDecoration.underline,
  );

  // ---- header ---------------------------------------------------------------

  List<_Contact> _contacts() {
    final p = resume.personalInfo;
    final list = <_Contact>[];
    final email = ResumeText.clean(p.email);
    if (email.isNotEmpty) {
      list.add(_Contact(_IconKind.email, email, ResumeLinks.normalize(email)));
    }
    final phone = ResumeText.clean(p.phone);
    if (phone.isNotEmpty) {
      list.add(_Contact(_IconKind.phone, phone, ResumeLinks.phone(phone)));
    }
    final location = ResumeText.clean(p.location);
    if (location.isNotEmpty) {
      list.add(_Contact(_IconKind.location, location, null));
    }
    final linkedin = ResumeLinks.normalize(p.linkedin);
    if (linkedin != null) {
      list.add(
        _Contact(_IconKind.linkedin, ResumeLinks.display(linkedin), linkedin),
      );
    }
    final github = ResumeLinks.normalize(p.github);
    if (github != null) {
      list.add(_Contact(_IconKind.github, ResumeLinks.display(github), github));
    }
    final website = ResumeLinks.normalize(p.website);
    if (website != null) {
      list.add(
        _Contact(_IconKind.website, ResumeLinks.display(website), website),
      );
    }
    return list;
  }

  pw.Widget _contactWidget(_Contact c) {
    final text = pw.Text(
      c.label,
      style: c.destination == null
          ? pw.TextStyle(fontSize: s.metaSize, color: s.ink)
          : _linkStyle(s.metaSize),
    );
    final row = pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _PdfIcon.build(c.icon, 9, s.accent),
        pw.SizedBox(width: 4),
        text,
      ],
    );
    final destination = c.destination;
    if (destination == null) return row;
    return pw.UrlLink(destination: destination, child: row);
  }

  pw.Widget _header() {
    final p = resume.personalInfo;
    final nameText = ResumeText.clean(p.fullName);
    final name = nameText.isEmpty ? 'Your Name' : nameText;
    final job = ResumeText.clean(p.jobTitle);
    final contacts = _contacts();
    final contactWidgets = <pw.Widget>[
      for (final c in contacts) _contactWidget(c),
    ];

    switch (s.header) {
      case _HeaderKind.split:
        return pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: s.accent, width: 2)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      name,
                      style: pw.TextStyle(
                        fontSize: s.nameSize,
                        color: s.accent,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (job.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        job,
                        style: pw.TextStyle(
                          fontSize: s.titleSize,
                          color: s.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    for (final w in contactWidgets)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 3),
                        child: w,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      case _HeaderKind.plain:
        return pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: s.rule, width: 0.6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: s.nameSize,
                  color: s.ink,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (job.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  job,
                  style: pw.TextStyle(fontSize: s.titleSize, color: s.muted),
                ),
              ],
              if (contactWidgets.isNotEmpty) ...[
                pw.SizedBox(height: 7),
                pw.Wrap(spacing: 12, runSpacing: 4, children: contactWidgets),
              ],
            ],
          ),
        );
      case _HeaderKind.centered:
        return pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: s.ink, width: 1.2)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                name,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: s.nameSize,
                  color: s.ink,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (job.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  job,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: s.titleSize, color: s.muted),
                ),
              ],
              if (contactWidgets.isNotEmpty) ...[
                pw.SizedBox(height: 7),
                pw.Wrap(
                  alignment: pw.WrapAlignment.center,
                  runAlignment: pw.WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: contactWidgets,
                ),
              ],
            ],
          ),
        );
    }
  }

  // ---- sections -------------------------------------------------------------

  List<pw.Widget> _section(String title, List<pw.Widget> body) {
    if (body.isEmpty) return const <pw.Widget>[];
    final heading = _sectionHeading(title);
    return <pw.Widget>[
      pw.SizedBox(height: s.sectionGap),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [heading, body.first],
      ),
      ...body.sublist(1),
    ];
  }

  pw.Widget _sectionHeading(String title) {
    switch (s.section) {
      case _SectionKind.accentBar:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 4,
                height: s.sectionSize + 2,
                color: s.accent,
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: s.sectionSize,
                  color: s.accent,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(child: pw.Container(height: 0.6, color: s.rule)),
            ],
          ),
        );
      case _SectionKind.quiet:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: s.sectionSize,
                  color: s.muted,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Container(height: 0.4, color: s.rule),
            ],
          ),
        );
      case _SectionKind.ruled:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 7),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: s.sectionSize,
                  color: s.ink,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Container(height: 0.9, color: s.rule),
            ],
          ),
        );
    }
  }

  // ---- entry builders: each returns [headerBlock, bullets..., spacer] --------

  pw.Widget _lineText(
    String text, {
    bool bold = false,
    bool muted = true,
    double? size,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 1.5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: size ?? s.metaSize,
          color: muted ? s.muted : s.ink,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _entryHeader(String title, List<pw.Widget> lines) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) pw.Text(title, style: _heading()),
        ...lines,
      ],
    );
  }

  pw.Widget _bullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 6, top: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 3,
            height: 3,
            margin: pw.EdgeInsets.only(top: s.bodySize * 0.5, right: 7),
            decoration: pw.BoxDecoration(
              color: s.ink,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(child: pw.Text(text, style: _body())),
        ],
      ),
    );
  }

  pw.Widget _label(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 5),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: s.metaSize,
        color: s.ink,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );

  pw.Widget _linkLine(String label, String? raw) {
    final url = ResumeLinks.normalize(raw);
    if (url == null) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          pw.Text(
            '$label: ',
            style: pw.TextStyle(
              fontSize: s.metaSize,
              color: s.ink,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Expanded(
            child: pw.UrlLink(
              destination: url,
              child: pw.Text(
                ResumeLinks.display(url),
                style: _linkStyle(s.metaSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _gap() => pw.SizedBox(height: s.entryGap);

  List<pw.Widget> _experience(Experience e) {
    final position = ResumeText.clean(e.position);
    final company = ResumeText.clean(e.company);
    final location = ResumeText.clean(e.location);
    final dates = ResumeText.dateRange(e.startDate, e.endDate, e.isCurrent);
    final bullets = ResumeText.cleanList(e.description);
    if (position.isEmpty && company.isEmpty && bullets.isEmpty) {
      return const <pw.Widget>[];
    }

    return <pw.Widget>[
      _entryHeader(position, [
        if (company.isNotEmpty)
          _lineText(company, bold: true, muted: false, size: s.bodySize),
        if (location.isNotEmpty) _lineText(location),
        if (dates.isNotEmpty) _lineText(dates),
      ]),
      for (final b in bullets) _bullet(b),
      _gap(),
    ];
  }

  List<pw.Widget> _project(Project e) {
    final name = ResumeText.clean(e.name);
    final role = ResumeText.clean(e.role);
    final bullets = ResumeText.cleanList(e.description);
    final tech = ResumeText.cleanList(e.technologies);
    final hasGithub = ResumeLinks.normalize(e.githubUrl) != null;
    final hasLive = ResumeLinks.normalize(e.liveUrl) != null;
    if (name.isEmpty &&
        bullets.isEmpty &&
        tech.isEmpty &&
        !hasGithub &&
        !hasLive)
      return const <pw.Widget>[];

    return <pw.Widget>[
      _entryHeader(name, [if (role.isNotEmpty) _lineText(role)]),
      if (bullets.isNotEmpty) pw.SizedBox(height: 3),
      for (final b in bullets) _bullet(b),
      if (tech.isNotEmpty) _label('Technologies:'),
      for (final t in tech) _bullet(t),
      if (hasGithub) _linkLine('GitHub', e.githubUrl),
      if (hasLive) _linkLine('Live Demo', e.liveUrl),
      _gap(),
    ];
  }

  List<pw.Widget> _skillGroup(SkillGroup e) {
    final category = ResumeText.clean(e.category);
    final items = ResumeText.cleanList(e.items);
    if (category.isEmpty && items.isEmpty) return const <pw.Widget>[];
    return <pw.Widget>[
      _entryHeader(category, const <pw.Widget>[]),
      if (items.isNotEmpty) pw.SizedBox(height: 2),
      for (final i in items) _bullet(i),
      _gap(),
    ];
  }

  List<pw.Widget> _course(Course e) {
    final name = ResumeText.clean(e.name);
    final provider = ResumeText.clean(e.provider);
    final date = ResumeText.clean(e.date);
    final lines = ResumeText.lines(e.description);
    final hasUrl = ResumeLinks.normalize(e.credentialUrl) != null;
    if (name.isEmpty && provider.isEmpty && lines.isEmpty && !hasUrl) {
      return const <pw.Widget>[];
    }
    return <pw.Widget>[
      _entryHeader(name, [
        if (provider.isNotEmpty)
          _lineText(provider, bold: true, muted: false, size: s.bodySize),
        if (date.isNotEmpty) _lineText(date),
      ]),
      for (final l in lines) _bullet(l),
      if (hasUrl) _linkLine('Credential', e.credentialUrl),
      _gap(),
    ];
  }

  List<pw.Widget> _education(Education e) {
    final degree = ResumeText.clean(e.degree);
    final institution = ResumeText.clean(e.institution);
    final location = ResumeText.clean(e.location);
    final dates = ResumeText.dateRange(e.startDate, e.endDate, e.isCurrent);
    final lines = ResumeText.lines(e.description);
    if (degree.isEmpty && institution.isEmpty && lines.isEmpty) {
      return const <pw.Widget>[];
    }
    return <pw.Widget>[
      _entryHeader(degree, [
        if (institution.isNotEmpty)
          _lineText(institution, bold: true, muted: false, size: s.bodySize),
        if (location.isNotEmpty) _lineText(location),
        if (dates.isNotEmpty) _lineText(dates),
      ]),
      for (final l in lines) _bullet(l),
      _gap(),
    ];
  }

  List<pw.Widget> _language(Language e) {
    final name = ResumeText.clean(e.name);
    final level = ResumeText.clean(e.level);
    if (name.isEmpty && level.isEmpty) return const <pw.Widget>[];
    return <pw.Widget>[
      _entryHeader(name, [if (level.isNotEmpty) _lineText(level)]),
      pw.SizedBox(height: s.entryGap - 2),
    ];
  }
}

class _PdfIcon {
  const _PdfIcon._();

  static pw.Widget build(_IconKind kind, double size, PdfColor color) {
    switch (kind) {
      case _IconKind.linkedin:
        return _badge('in', size, color, circle: false);
      case _IconKind.github:
        return _badge('</>', size, color, circle: true);
      case _IconKind.email:
      case _IconKind.phone:
      case _IconKind.location:
      case _IconKind.website:
        return pw.SizedBox(
          width: size,
          height: size,
          child: pw.CustomPaint(
            size: PdfPoint(size, size),
            painter: (PdfGraphics canvas, PdfPoint box) =>
                _paint(canvas, kind, size, color),
          ),
        );
    }
  }

  static pw.Widget _badge(
    String text,
    double size,
    PdfColor color, {
    required bool circle,
  }) {
    return pw.Container(
      width: size,
      height: size,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: color,
        shape: circle ? pw.BoxShape.circle : pw.BoxShape.rectangle,
        borderRadius: circle
            ? null
            : const pw.BorderRadius.all(pw.Radius.circular(1.5)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: text.length > 2 ? size * 0.42 : size * 0.62,
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static void _paint(PdfGraphics c, _IconKind kind, double s, PdfColor color) {
    c
      ..setStrokeColor(color)
      ..setFillColor(color)
      ..setLineWidth(0.8)
      ..setLineCap(PdfLineCap.round)
      ..setLineJoin(PdfLineJoin.round);

    switch (kind) {
      case _IconKind.email:
        c
          ..drawRRect(0.3, s * 0.2, s - 0.6, s * 0.6, 1, 1)
          ..strokePath()
          ..moveTo(0.6, s * 0.76)
          ..lineTo(s / 2, s * 0.42)
          ..lineTo(s - 0.6, s * 0.76)
          ..strokePath();
      case _IconKind.phone:
        c
          ..drawRRect(s * 0.25, 0.3, s * 0.5, s - 0.6, 1.2, 1.2)
          ..strokePath()
          ..moveTo(s * 0.4, s * 0.15)
          ..lineTo(s * 0.6, s * 0.15)
          ..strokePath();
      case _IconKind.location:
        c
          ..moveTo(s * 0.2, s * 0.5)
          ..lineTo(s / 2, 0.2)
          ..lineTo(s * 0.8, s * 0.5)
          ..strokePath()
          ..drawEllipse(s / 2, s * 0.62, s * 0.3, s * 0.3)
          ..strokePath()
          ..drawEllipse(s / 2, s * 0.62, s * 0.1, s * 0.1)
          ..fillPath();
      case _IconKind.website:
        c
          ..drawEllipse(s / 2, s / 2, s * 0.45, s * 0.45)
          ..strokePath()
          ..drawEllipse(s / 2, s / 2, s * 0.2, s * 0.45)
          ..strokePath()
          ..moveTo(s * 0.05, s / 2)
          ..lineTo(s * 0.95, s / 2)
          ..strokePath();
      case _IconKind.linkedin:
      case _IconKind.github:
        break;
    }
  }
}
