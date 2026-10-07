import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/personal_info.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/skill_group.dart';
import '../../domain/usecases/create_resume.dart';
import '../../domain/usecases/update_resume.dart';
import '../../services/resume_pdf_service.dart';
import '../cubit/resume_editor_cubit.dart';
import '../cubit/resume_editor_state.dart';
import '../widgets/entry_dialog.dart';

class ResumeEditorPage extends StatelessWidget {
  final Resume resume;

  const ResumeEditorPage({super.key, required this.resume});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ResumeEditorCubit(
          create: getIt<CreateResume>(),
          update: getIt<UpdateResume>(),
          resume: resume,
        ),
        child: _EditorView(initial: resume),
      );
}

String? _nullIfBlank(String s) => s.trim().isEmpty ? null : s.trim();

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

class _EditorView extends StatefulWidget {
  final Resume initial;
  const _EditorView({required this.initial});

  @override
  State<_EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<_EditorView> {
  // Controllers live in State: created once, disposed once.
  late final TextEditingController _title;
  late final TextEditingController _name;
  late final TextEditingController _job;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _linkedin;
  late final TextEditingController _github;
  late final TextEditingController _website;
  late final TextEditingController _summary;

  bool _pdfBusy = false;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    final p = r.personalInfo;
    _title = TextEditingController(text: r.title);
    _name = TextEditingController(text: p.fullName);
    _job = TextEditingController(text: p.jobTitle);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
    _location = TextEditingController(text: p.location);
    _linkedin = TextEditingController(text: p.linkedin ?? '');
    _github = TextEditingController(text: p.github ?? '');
    _website = TextEditingController(text: p.website ?? '');
    _summary = TextEditingController(text: r.summary);
  }

  @override
  void dispose() {
    for (final c in <TextEditingController>[
      _title, _name, _job, _email, _phone, _location, _linkedin, _github, _website, _summary,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ResumeEditorCubit get _cubit => context.read<ResumeEditorCubit>();

  void _pushPersonal() {
    _cubit.setPersonalInfo(
      PersonalInfo(
        fullName: _name.text.trim(),
        jobTitle: _job.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        location: _location.text.trim(),
        linkedin: _nullIfBlank(_linkedin.text),
        github: _nullIfBlank(_github.text),
        website: _nullIfBlank(_website.text),
      ),
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save({required bool complete}) async {
    final cubit = _cubit;
    final outcome = complete ? await cubit.completeResume() : await cubit.saveDraft();
    if (!mounted) return;
    switch (outcome) {
      case SaveOutcome.saved:
        _toast(complete ? 'Resume completed' : 'Draft saved');
        if (complete && context.canPop()) context.pop();
      case SaveOutcome.nothingToSave:
        _toast('Add some resume content first - nothing was saved.');
      case SaveOutcome.failed:
        _toast('Could not save: ${cubit.state.error ?? 'unknown error'}');
    }
  }

  Future<void> _pdf(Future<void> Function(Resume) action) async {
    if (_pdfBusy) return;
    setState(() => _pdfBusy = true);
    try {
      await action(_cubit.state.resume);
    } on ResumePdfException catch (e) {
      _toast(e.message);
    } catch (e, st) {
      debugPrint('Unexpected PDF error: $e\n$st');
      _toast('PDF generation failed: $e');
    } finally {
      if (mounted) setState(() => _pdfBusy = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes that will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
        ],
      ),
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, shell) {
        return PopScope(
          // Always intercept back; decide at pop time so the answer is never
          // stale. Navigator.pop()/context.pop() below bypass PopScope.
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final unsaved = _cubit.state.dirty && _cubit.canPersist;
            if (unsaved && !await _confirmDiscard()) return;
            if (mounted && context.mounted && context.canPop()) context.pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Resume Editor'),
              actions: [
                IconButton(
                  tooltip: 'Preview',
                  icon: const Icon(Icons.visibility_outlined),
                  onPressed: () => context.push('/resumes/preview', extra: _cubit.state.resume),
                ),
                IconButton(
                  tooltip: 'Export PDF',
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: _pdfBusy ? null : () => _pdf(ResumePdfService.export),
                ),
                IconButton(
                  tooltip: 'Share PDF',
                  icon: const Icon(Icons.ios_share_outlined),
                  onPressed: _pdfBusy ? null : () => _pdf(ResumePdfService.share),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: shell.status == EditorStatus.saving ? null : () => _save(complete: false),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: shell.status == EditorStatus.saving ? null : () => _save(complete: true),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete'),
                    ),
                  ),
                ],
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
                  builder: (context, state) => _EditorHero(resume: state.resume, dirty: state.dirty),
                ),
                _card('Resume', _basicFields()),
                _card('Personal Information', _personalFields()),
                _card(
                  'Professional Summary',
                  TextField(
                    controller: _summary,
                    minLines: 4,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (v) => _cubit.setSummary(v),
                    decoration: const InputDecoration(hintText: 'Write a short professional summary...'),
                  ),
                ),
                BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
                  buildWhen: (a, b) => a.resume != b.resume,
                  builder: (context, state) => _lists(state.resume),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _basicFields() {
    return Column(
      children: [
        TextField(
          controller: _title,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => _cubit.setTitle(v),
          decoration: const InputDecoration(labelText: 'Resume title'),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
          buildWhen: (a, b) => a.resume.templateId != b.resume.templateId || a.resume.isPublic != b.resume.isPublic,
          builder: (context, state) => Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: state.resume.templateId,
                decoration: const InputDecoration(labelText: 'Template'),
                items: const [
                  DropdownMenuItem(value: 'classic_01', child: Text('Classic ATS')),
                  DropdownMenuItem(value: 'modern_01', child: Text('Modern ATS')),
                  DropdownMenuItem(value: 'minimal_01', child: Text('Minimal ATS')),
                ],
                onChanged: (v) {
                  if (v != null) _cubit.setTemplate(v);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Publish resume'),
                value: state.resume.isPublic,
                onChanged: (v) => _cubit.setPublic(v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _personalFields() {
    return Column(
      children: [
        _field(_name, 'Full name', Icons.person_outline, capitalization: TextCapitalization.words),
        _field(_job, 'Job title', Icons.work_outline, capitalization: TextCapitalization.words),
        _field(_email, 'Email', Icons.email_outlined, keyboard: TextInputType.emailAddress),
        _field(_phone, 'Phone', Icons.phone_outlined, keyboard: TextInputType.phone),
        _field(_location, 'Location', Icons.location_on_outlined, capitalization: TextCapitalization.words),
        _field(_linkedin, 'LinkedIn', Icons.business_center_outlined, keyboard: TextInputType.url),
        _field(_github, 'GitHub', Icons.code_outlined, keyboard: TextInputType.url),
        _field(_website, 'Website', Icons.link_outlined, keyboard: TextInputType.url, last: true),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    bool last = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        textCapitalization: capitalization,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        autocorrect: keyboard == null,
        onChanged: (_) => _pushPersonal(),
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Repeating sections
  // ---------------------------------------------------------------------------

  Widget _lists(Resume r) {
    return Column(
      children: [
        _ListSection<Education>(
          title: 'Education',
          items: r.education,
          label: (e) => _join(e.degree, e.institution),
          onAdd: () => _educationDialog(),
          onEdit: (i) => _educationDialog(item: r.education[i], index: i),
          onDelete: (i) => _cubit.setEducation([...r.education]..removeAt(i)),
        ),
        _ListSection<Experience>(
          title: 'Experience',
          items: r.experience,
          label: (e) => _join(e.position, e.company),
          onAdd: () => _experienceDialog(),
          onEdit: (i) => _experienceDialog(item: r.experience[i], index: i),
          onDelete: (i) => _cubit.setExperience([...r.experience]..removeAt(i)),
        ),
        _ListSection<Course>(
          title: 'Courses',
          items: r.courses,
          label: (e) => _join(e.name, e.provider),
          onAdd: () => _courseDialog(),
          onEdit: (i) => _courseDialog(item: r.courses[i], index: i),
          onDelete: (i) => _cubit.setCourses([...r.courses]..removeAt(i)),
        ),
        _ListSection<Project>(
          title: 'Projects',
          items: r.projects,
          label: (e) => _join(e.name, e.role),
          onAdd: () => _projectDialog(),
          onEdit: (i) => _projectDialog(item: r.projects[i], index: i),
          onDelete: (i) => _cubit.setProjects([...r.projects]..removeAt(i)),
        ),
        _ListSection<SkillGroup>(
          title: 'Skills',
          items: r.skills,
          label: (e) => e.items.isEmpty ? e.category : '${e.category}: ${e.items.join(', ')}',
          onAdd: () => _skillDialog(),
          onEdit: (i) => _skillDialog(item: r.skills[i], index: i),
          onDelete: (i) => _cubit.setSkills([...r.skills]..removeAt(i)),
        ),
        _ListSection<Language>(
          title: 'Languages',
          items: r.languages,
          label: (e) => _join(e.name, e.level),
          onAdd: () => _languageDialog(),
          onEdit: (i) => _languageDialog(item: r.languages[i], index: i),
          onDelete: (i) => _cubit.setLanguages([...r.languages]..removeAt(i)),
        ),
      ],
    );
  }

  static String _join(String a, String b) {
    final x = a.trim();
    final y = b.trim();
    if (x.isNotEmpty && y.isNotEmpty) return '$x - $y';
    return x.isNotEmpty ? x : (y.isNotEmpty ? y : '(untitled)');
  }

  static List<String> _splitLines(String text) {
    final out = <String>[];
    for (final raw in text.split('\n')) {
      final t = raw.trim();
      if (t.isNotEmpty) out.add(t);
    }
    return out;
  }

  static List<String> _splitCommas(String text) {
    final out = <String>[];
    for (final raw in text.split(RegExp(r'[,\n]'))) {
      final t = raw.trim();
      if (t.isNotEmpty) out.add(t);
    }
    return out;
  }

  List<T> _upsert<T>(List<T> list, T value, int? index) {
    final copy = [...list];
    if (index == null) {
      copy.add(value);
    } else {
      copy[index] = value;
    }
    return copy;
  }

  Future<void> _educationDialog({Education? item, int? index}) async {
    final r = await showEntryDialog(
      context,
      title: item == null ? 'Add Education' : 'Edit Education',
      fields: [
        EntryField('institution', 'Institution', initial: item?.institution ?? '', capitalization: TextCapitalization.words),
        EntryField('degree', 'Degree', initial: item?.degree ?? '', capitalization: TextCapitalization.words),
        EntryField('location', 'Location', initial: item?.location ?? '', capitalization: TextCapitalization.words),
        EntryField('start', 'Start date', initial: item?.startDate ?? ''),
        EntryField('end', 'End date', initial: item?.endDate ?? ''),
        EntryField('description', 'Description (one line per bullet)', initial: item?.description ?? '', multiline: true),
      ],
      currentLabel: 'Currently studying',
      current: item?.isCurrent ?? false,
    );
    if (r == null || !mounted) return;
    final cubit = _cubit;
    final list = cubit.state.resume.education;
    cubit.setEducation(_upsert(
      list,
      Education(
        id: item?.id ?? _newId(),
        institution: r['institution'],
        degree: r['degree'],
        location: r['location'],
        startDate: r['start'],
        endDate: _nullIfBlank(r['end']),
        isCurrent: r.current,
        description: _nullIfBlank(r['description']),
        order: index ?? list.length,
      ),
      index,
    ));
  }

  Future<void> _experienceDialog({Experience? item, int? index}) async {
    final r = await showEntryDialog(
      context,
      title: item == null ? 'Add Experience' : 'Edit Experience',
      fields: [
        EntryField('company', 'Company', initial: item?.company ?? '', capitalization: TextCapitalization.words),
        EntryField('position', 'Position', initial: item?.position ?? '', capitalization: TextCapitalization.words),
        EntryField('location', 'Location', initial: item?.location ?? '', capitalization: TextCapitalization.words),
        EntryField('start', 'Start date', initial: item?.startDate ?? ''),
        EntryField('end', 'End date', initial: item?.endDate ?? ''),
        EntryField('description', 'Responsibilities (one line per bullet)', initial: item?.description.join('\n') ?? '', multiline: true),
      ],
      currentLabel: 'I currently work here',
      current: item?.isCurrent ?? false,
    );
    if (r == null || !mounted) return;
    final cubit = _cubit;
    final list = cubit.state.resume.experience;
    cubit.setExperience(_upsert(
      list,
      Experience(
        id: item?.id ?? _newId(),
        company: r['company'],
        position: r['position'],
        location: r['location'],
        startDate: r['start'],
        endDate: _nullIfBlank(r['end']),
        isCurrent: r.current,
        description: _splitLines(r['description']),
        order: index ?? list.length,
      ),
      index,
    ));
  }

  Future<void> _courseDialog({Course? item, int? index}) async {
    final r = await showEntryDialog(
      context,
      title: item == null ? 'Add Course' : 'Edit Course',
      fields: [
        EntryField('name', 'Course / certification', initial: item?.name ?? '', capitalization: TextCapitalization.words),
        EntryField('provider', 'Provider', initial: item?.provider ?? '', capitalization: TextCapitalization.words),
        EntryField('date', 'Date', initial: item?.date ?? ''),
        EntryField('url', 'Credential URL', initial: item?.credentialUrl ?? '', keyboard: TextInputType.url),
        EntryField('description', 'Description', initial: item?.description ?? '', multiline: true),
      ],
    );
    if (r == null || !mounted) return;
    final cubit = _cubit;
    final list = cubit.state.resume.courses;
    cubit.setCourses(_upsert(
      list,
      Course(
        id: item?.id ?? _newId(),
        name: r['name'],
        provider: r['provider'],
        date: r['date'],
        credentialUrl: _nullIfBlank(r['url']),
        description: _nullIfBlank(r['description']),
        order: index ?? list.length,
      ),
      index,
    ));
  }

  Future<void> _projectDialog({Project? item, int? index}) async {
    final r = await showEntryDialog(
      context,
      title: item == null ? 'Add Project' : 'Edit Project',
      fields: [
        EntryField('name', 'Name', initial: item?.name ?? '', capitalization: TextCapitalization.words),
        EntryField('role', 'Role', initial: item?.role ?? '', capitalization: TextCapitalization.words),
        EntryField('description', 'Description (one line per bullet)', initial: item?.description.join('\n') ?? '', multiline: true),
        EntryField('tech', 'Technologies (comma separated)', initial: item?.technologies.join(', ') ?? '', multiline: true),
        EntryField('github', 'GitHub URL', initial: item?.githubUrl ?? '', keyboard: TextInputType.url),
        EntryField('live', 'Live demo URL', initial: item?.liveUrl ?? '', keyboard: TextInputType.url),
      ],
    );
    if (r == null || !mounted) return;
    final cubit = _cubit;
    final list = cubit.state.resume.projects;
    cubit.setProjects(_upsert(
      list,
      Project(
        id: item?.id ?? _newId(),
        name: r['name'],
        role: r['role'],
        description: _splitLines(r['description']),
        technologies: _splitCommas(r['tech']),
        githubUrl: _nullIfBlank(r['github']),
        liveUrl: _nullIfBlank(r['live']),
        order: index ?? list.length,
      ),
      index,
    ));
  }

  Future<void> _skillDialog({SkillGroup? item, int? index}) async {
    final r = await showEntryDialog(
      context,
      title: item == null ? 'Add Skills' : 'Edit Skills',
      fields: [
        EntryField('category', 'Category (e.g. Programming)', initial: item?.category ?? '', capitalization: TextCapitalization.words),
        EntryField('items', 'Skills (comma separated)', initial: item?.items.join(', ') ?? '', multiline: true),
      ],
    );
    if (r == null || !mounted) return;
    final cubit = _cubit;
    final list = cubit.state.resume.skills;
    cubit.setSkills(_upsert(
      list,
      SkillGroup(
        id: item?.id ?? _newId(),
        category: r['category'],
        items: _splitCommas(r['items']),
        order: index ?? list.length,
      ),
      index,
    ));
  }

  Future<void> _languageDialog({Language? item, int? index}) async {
    final r = await showEntryDialog(
      context,
      title: item == null ? 'Add Language' : 'Edit Language',
      fields: [
        EntryField('name', 'Language', initial: item?.name ?? '', capitalization: TextCapitalization.words),
        EntryField('level', 'Level (e.g. Native)', initial: item?.level ?? '', capitalization: TextCapitalization.words),
      ],
    );
    if (r == null || !mounted) return;
    final cubit = _cubit;
    final list = cubit.state.resume.languages;
    cubit.setLanguages(_upsert(
      list,
      Language(
        id: item?.id ?? _newId(),
        name: r['name'],
        level: r['level'],
        order: index ?? list.length,
      ),
      index,
    ));
  }
}

Widget _card(String title, Widget child) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );

class _ListSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) label;
  final VoidCallback onAdd;
  final void Function(int) onEdit;
  final void Function(int) onDelete;

  const _ListSection({
    required this.title,
    required this.items,
    required this.label,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => _card(
        title,
        Column(
          children: [
            for (var i = 0; i < items.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(label(items[i]), maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => onEdit(i),
                trailing: IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(i),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ),
          ],
        ),
      );
}

class _EditorHero extends StatelessWidget {
  final Resume resume;
  final bool dirty;
  const _EditorHero({required this.resume, required this.dirty});

  @override
  Widget build(BuildContext context) {
    var filled = 0;
    final p = resume.personalInfo;
    for (final v in <String>[p.fullName, p.jobTitle, resume.summary]) {
      if (v.trim().isNotEmpty) filled++;
    }
    filled += resume.education.length +
        resume.experience.length +
        resume.projects.length +
        resume.skills.length +
        resume.languages.length;
    final progress = (filled / 10).clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.auto_awesome, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Build a resume that gets noticed',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dirty ? 'You have unsaved changes.' : 'Start with the basics, then add your strongest evidence.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).round()}% profile strength', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
