import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/personal_info.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/skill_group.dart';
import '../../services/resume_formatters.dart';
import '../../services/resume_pdf_service.dart';

class ResumePreviewPage extends StatefulWidget {
  final Resume resume;
  const ResumePreviewPage({super.key, required this.resume});

  @override
  State<ResumePreviewPage> createState() => _ResumePreviewPageState();
}

class _ResumePreviewPageState extends State<ResumePreviewPage> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(Resume) action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action(widget.resume);
    } on ResumePdfException catch (e) {
      _toast(e.message);
    } catch (e, st) {
      debugPrint('Unexpected PDF error: $e\n$st');
      _toast('PDF generation failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final resume = widget.resume;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _busy ? null : () => _run(ResumePdfService.export),
          ),
          IconButton(
            tooltip: 'Share PDF',
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: _busy ? null : () => _run(ResumePdfService.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            // A resume is a white sheet of paper regardless of app theme.
            child: Theme(
              data: ThemeData.light(useMaterial3: true),
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 28, 26, 36),
                  child: _ResumeSheet(resume: resume),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const Color _ink = Color(0xFF1B1B1F);
const Color _muted = Color(0xFF555B66);
const Color _linkColor = Color(0xFF0B5CAD);

class _ResumeSheet extends StatelessWidget {
  final Resume resume;
  const _ResumeSheet({required this.resume});

  @override
  Widget build(BuildContext context) {
    final summary = ResumeText.clean(resume.summary);

    final experience = <Widget>[for (final e in resume.experience) ..._experience(e)];
    final projects = <Widget>[for (final e in resume.projects) ..._project(e)];
    final skills = <Widget>[for (final e in resume.skills) ..._skills(e)];
    final courses = <Widget>[for (final e in resume.courses) ..._course(e)];
    final education = <Widget>[for (final e in resume.education) ..._education(e)];
    final languages = <Widget>[for (final e in resume.languages) ..._language(e)];

    return DefaultTextStyle(
      style: const TextStyle(color: _ink, fontSize: 14, height: 1.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(info: resume.personalInfo),
          if (summary.isNotEmpty)
            _Section(title: 'PROFESSIONAL SUMMARY', children: [for (final l in ResumeText.lines(summary)) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(l))]),
          if (experience.isNotEmpty) _Section(title: 'PROFESSIONAL EXPERIENCE', children: experience),
          if (projects.isNotEmpty) _Section(title: 'PROJECTS', children: projects),
          if (skills.isNotEmpty) _Section(title: 'TECHNICAL SKILLS', children: skills),
          if (courses.isNotEmpty) _Section(title: 'COURSES & CERTIFICATIONS', children: courses),
          if (education.isNotEmpty) _Section(title: 'EDUCATION', children: education),
          if (languages.isNotEmpty) _Section(title: 'LANGUAGES', children: languages),
        ],
      ),
    );
  }

  List<Widget> _experience(Experience e) {
    final position = ResumeText.clean(e.position);
    final company = ResumeText.clean(e.company);
    final location = ResumeText.clean(e.location);
    final dates = ResumeText.dateRange(e.startDate, e.endDate, e.isCurrent);
    final bullets = ResumeText.cleanList(e.description);
    if (position.isEmpty && company.isEmpty && bullets.isEmpty) return const <Widget>[];
    return <Widget>[
      _Entry(
        title: position,
        lines: [
          if (company.isNotEmpty) _Line(company, strong: true),
          if (location.isNotEmpty) _Line(location),
          if (dates.isNotEmpty) _Line(dates),
        ],
        bullets: bullets,
      ),
    ];
  }

  List<Widget> _project(Project e) {
    final name = ResumeText.clean(e.name);
    final role = ResumeText.clean(e.role);
    final bullets = ResumeText.cleanList(e.description);
    final tech = ResumeText.cleanList(e.technologies);
    final github = ResumeLinks.normalize(e.githubUrl);
    final live = ResumeLinks.normalize(e.liveUrl);
    if (name.isEmpty && bullets.isEmpty && tech.isEmpty && github == null && live == null) return const <Widget>[];
    return <Widget>[
      _Entry(
        title: name,
        lines: [if (role.isNotEmpty) _Line(role)],
        bullets: bullets,
        extra: [
          if (tech.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.only(top: 6), child: Text('Technologies:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
            for (final t in tech) _Bullet(t),
          ],
          if (github != null) _LinkRow(label: 'GitHub', url: github),
          if (live != null) _LinkRow(label: 'Live Demo', url: live),
        ],
      ),
    ];
  }

  List<Widget> _skills(SkillGroup e) {
    final category = ResumeText.clean(e.category);
    final items = ResumeText.cleanList(e.items);
    if (category.isEmpty && items.isEmpty) return const <Widget>[];
    return <Widget>[_Entry(title: category, lines: const <Widget>[], bullets: items)];
  }

  List<Widget> _course(Course e) {
    final name = ResumeText.clean(e.name);
    final provider = ResumeText.clean(e.provider);
    final date = ResumeText.clean(e.date);
    final lines = ResumeText.lines(e.description);
    final url = ResumeLinks.normalize(e.credentialUrl);
    if (name.isEmpty && provider.isEmpty && lines.isEmpty && url == null) return const <Widget>[];
    return <Widget>[
      _Entry(
        title: name,
        lines: [
          if (provider.isNotEmpty) _Line(provider, strong: true),
          if (date.isNotEmpty) _Line(date),
        ],
        bullets: lines,
        extra: [if (url != null) _LinkRow(label: 'Credential', url: url)],
      ),
    ];
  }

  List<Widget> _education(Education e) {
    final degree = ResumeText.clean(e.degree);
    final institution = ResumeText.clean(e.institution);
    final location = ResumeText.clean(e.location);
    final dates = ResumeText.dateRange(e.startDate, e.endDate, e.isCurrent);
    final lines = ResumeText.lines(e.description);
    if (degree.isEmpty && institution.isEmpty && lines.isEmpty) return const <Widget>[];
    return <Widget>[
      _Entry(
        title: degree,
        lines: [
          if (institution.isNotEmpty) _Line(institution, strong: true),
          if (location.isNotEmpty) _Line(location),
          if (dates.isNotEmpty) _Line(dates),
        ],
        bullets: lines,
      ),
    ];
  }

  List<Widget> _language(Language e) {
    final name = ResumeText.clean(e.name);
    final level = ResumeText.clean(e.level);
    if (name.isEmpty && level.isEmpty) return const <Widget>[];
    return <Widget>[
      _Entry(title: name, lines: [if (level.isNotEmpty) _Line(level)], bullets: const <String>[]),
    ];
  }
}

class _Header extends StatelessWidget {
  final PersonalInfo info;
  const _Header({required this.info});

  @override
  Widget build(BuildContext context) {
    final name = ResumeText.clean(info.fullName);
    final job = ResumeText.clean(info.jobTitle);

    final email = ResumeText.clean(info.email);
    final phone = ResumeText.clean(info.phone);
    final location = ResumeText.clean(info.location);
    final linkedin = ResumeLinks.normalize(info.linkedin);
    final github = ResumeLinks.normalize(info.github);
    final website = ResumeLinks.normalize(info.website);

    final contacts = <Widget>[
      if (email.isNotEmpty) _Contact(icon: Icons.mail_outline, text: email, url: ResumeLinks.normalize(email)),
      if (phone.isNotEmpty) _Contact(icon: Icons.phone_outlined, text: phone, url: ResumeLinks.phone(phone)),
      if (location.isNotEmpty) _Contact(icon: Icons.place_outlined, text: location),
      if (linkedin != null) _Contact(icon: Icons.business_center_outlined, text: ResumeLinks.display(linkedin), url: linkedin),
      if (github != null) _Contact(icon: Icons.code, text: ResumeLinks.display(github), url: github),
      if (website != null) _Contact(icon: Icons.language, text: ResumeLinks.display(website), url: website),
    ];

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name.isEmpty ? 'Your Name' : name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink),
          ),
          if (job.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(job, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: _muted)),
          ],
          if (contacts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 6, children: contacts),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1.2, color: _ink),
        ],
      ),
    );
  }
}

class _Contact extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? url;
  const _Contact({required this.icon, required this.text, this.url});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _muted),
        const SizedBox(width: 4),
        Flexible(child: _LinkText(text: text, url: url, size: 13)),
      ],
    );
    return content;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 4),
            const Divider(height: 1, thickness: 0.9, color: _muted),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );
}

class _Entry extends StatelessWidget {
  final String title;
  final List<Widget> lines;
  final List<String> bullets;
  final List<Widget> extra;

  const _Entry({
    required this.title,
    required this.lines,
    required this.bullets,
    this.extra = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ...lines,
            if (bullets.isNotEmpty) const SizedBox(height: 4),
            for (final b in bullets) _Bullet(b),
            ...extra,
          ],
        ),
      );
}

class _Line extends StatelessWidget {
  final String text;
  final bool strong;
  const _Line(this.text, {this.strong = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Text(
          text,
          style: TextStyle(
            fontSize: strong ? 14 : 13,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
            color: strong ? _ink : _muted,
          ),
        ),
      );
}

/// Bullet drawn as a small circle (no Unicode bullet glyph).
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 6, top: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 7, right: 8),
              child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: _ink, shape: BoxShape.circle))),
            ),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _LinkRow extends StatelessWidget {
  final String label;
  final String url;
  const _LinkRow({required this.label, required this.url});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            _LinkText(text: ResumeLinks.display(url), url: url, size: 13),
          ],
        ),
      );
}

class _LinkText extends StatelessWidget {
  final String text;
  final String? url;
  final double size;
  const _LinkText({required this.text, required this.url, required this.size});

  Future<void> _open(BuildContext context) async {
    final uri = ResumeLinks.toUri(url);
    if (uri == null) return;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $uri: $e');
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open ${ResumeLinks.display(url)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Text(text, style: TextStyle(fontSize: size, color: _ink));
    }
    return InkWell(
      onTap: () => _open(context),
      child: Text(
        text,
        style: TextStyle(fontSize: size, color: _linkColor, decoration: TextDecoration.underline, decorationColor: _linkColor),
      ),
    );
  }
}
