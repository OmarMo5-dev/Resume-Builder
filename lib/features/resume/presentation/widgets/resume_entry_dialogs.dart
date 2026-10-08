import 'package:flutter/material.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/skill_group.dart';
import '../widgets/entry_dialog.dart';

String? _nullIfBlank(String value) =>
    value.trim().isEmpty ? null : value.trim();

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

List<String> _splitLines(String value) => value
    .split('\n')
    .map((item) => item.trim())
    .where((item) => item.isNotEmpty)
    .toList();

List<String> _splitCommas(String value) => value
    .split(RegExp(r'[,\n]'))
    .map((item) => item.trim())
    .where((item) => item.isNotEmpty)
    .toList();

List<T> _upsert<T>(List<T> list, T value, int? index) {
  final copy = [...list];
  if (index == null) {
    copy.add(value);
  } else {
    copy[index] = value;
  }
  return copy;
}

Future<Education?> showEducationEditor(
  BuildContext context, {
  Education? item,
  int? index,
}) async {
  final result = await showEntryDialog(
    context,
    title: item == null ? 'Add education' : 'Edit education',
    subtitle: 'Keep it simple. Add the most relevant academic details.',
    fields: [
      EntryField(
        'institution',
        'Institution',
        initial: item?.institution ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. Al-Azhar University',
      ),
      EntryField(
        'degree',
        'Degree',
        initial: item?.degree ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. B.Sc. Computer Engineering',
      ),
      EntryField(
        'location',
        'Location',
        initial: item?.location ?? '',
        capitalization: TextCapitalization.words,
        hintText: 'e.g. Cairo, Egypt',
      ),
      EntryField('start', 'Start date', initial: item?.startDate ?? ''),
      EntryField('end', 'End date', initial: item?.endDate ?? ''),
      EntryField(
        'description',
        'Description',
        initial: item?.description ?? '',
        multiline: true,
        hintText: 'One point per line',
      ),
    ],
    currentLabel: 'I am currently studying here',
    current: item?.isCurrent ?? false,
  );

  if (result == null) return null;

  return Education(
    id: item?.id ?? _newId(),
    institution: result['institution'],
    degree: result['degree'],
    location: result['location'],
    startDate: result['start'],
    endDate: _nullIfBlank(result['end']),
    isCurrent: result.current,
    description: _nullIfBlank(result['description']),
    order: index ?? 0,
  );
}

Future<Experience?> showExperienceEditor(
  BuildContext context, {
  Experience? item,
  int? index,
}) async {
  final result = await showEntryDialog(
    context,
    title: item == null ? 'Add experience' : 'Edit experience',
    subtitle: 'Focus on impact, responsibilities, and measurable results.',
    fields: [
      EntryField(
        'company',
        'Company',
        initial: item?.company ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. Curve AI Solutions',
      ),
      EntryField(
        'position',
        'Position',
        initial: item?.position ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. Flutter Developer Intern',
      ),
      EntryField(
        'location',
        'Location',
        initial: item?.location ?? '',
        capitalization: TextCapitalization.words,
      ),
      EntryField('start', 'Start date', initial: item?.startDate ?? ''),
      EntryField('end', 'End date', initial: item?.endDate ?? ''),
      EntryField(
        'description',
        'Responsibilities & achievements',
        initial: item?.description.join('\n') ?? '',
        multiline: true,
        hintText: 'Built X...\nImproved Y...\nReduced Z...',
      ),
    ],
    currentLabel: 'I currently work here',
    current: item?.isCurrent ?? false,
  );

  if (result == null) return null;

  return Experience(
    id: item?.id ?? _newId(),
    company: result['company'],
    position: result['position'],
    location: result['location'],
    startDate: result['start'],
    endDate: _nullIfBlank(result['end']),
    isCurrent: result.current,
    description: _splitLines(result['description']),
    order: index ?? 0,
  );
}

Future<Project?> showProjectEditor(
  BuildContext context, {
  Project? item,
  int? index,
}) async {
  final result = await showEntryDialog(
    context,
    title: item == null ? 'Add project' : 'Edit project',
    subtitle: 'Show what you built and why it is worth mentioning.',
    fields: [
      EntryField(
        'name',
        'Project name',
        initial: item?.name ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. CV Builder',
      ),
      EntryField(
        'role',
        'Your role',
        initial: item?.role ?? '',
        capitalization: TextCapitalization.words,
        hintText: 'e.g. Flutter Developer',
      ),
      EntryField(
        'description',
        'Description',
        initial: item?.description.join('\n') ?? '',
        multiline: true,
        hintText: 'One achievement or feature per line',
      ),
      EntryField(
        'tech',
        'Technologies',
        initial: item?.technologies.join(', ') ?? '',
        multiline: true,
        hintText: 'Flutter, Firebase, Clean Architecture',
      ),
      EntryField(
        'github',
        'GitHub URL',
        initial: item?.githubUrl ?? '',
        keyboard: TextInputType.url,
      ),
      EntryField(
        'live',
        'Live demo URL',
        initial: item?.liveUrl ?? '',
        keyboard: TextInputType.url,
      ),
    ],
  );

  if (result == null) return null;

  return Project(
    id: item?.id ?? _newId(),
    name: result['name'],
    role: result['role'],
    description: _splitLines(result['description']),
    technologies: _splitCommas(result['tech']),
    githubUrl: _nullIfBlank(result['github']),
    liveUrl: _nullIfBlank(result['live']),
    order: index ?? 0,
  );
}

Future<SkillGroup?> showSkillEditor(
  BuildContext context, {
  SkillGroup? item,
  int? index,
}) async {
  final result = await showEntryDialog(
    context,
    title: item == null ? 'Add skills' : 'Edit skills',
    subtitle: 'Group related skills so recruiters can scan them quickly.',
    fields: [
      EntryField(
        'category',
        'Category',
        initial: item?.category ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. Programming',
      ),
      EntryField(
        'items',
        'Skills',
        initial: item?.items.join(', ') ?? '',
        multiline: true,
        required: true,
        hintText: 'Dart, Flutter, Firebase, Git',
      ),
    ],
  );

  if (result == null) return null;

  return SkillGroup(
    id: item?.id ?? _newId(),
    category: result['category'],
    items: _splitCommas(result['items']),
    order: index ?? 0,
  );
}

Future<Course?> showCourseEditor(
  BuildContext context, {
  Course? item,
  int? index,
}) async {
  final result = await showEntryDialog(
    context,
    title: item == null ? 'Add course' : 'Edit course',
    subtitle: 'Add certifications or courses that support your target role.',
    fields: [
      EntryField(
        'name',
        'Course / certification',
        initial: item?.name ?? '',
        capitalization: TextCapitalization.words,
        required: true,
      ),
      EntryField(
        'provider',
        'Provider',
        initial: item?.provider ?? '',
        capitalization: TextCapitalization.words,
      ),
      EntryField('date', 'Date', initial: item?.date ?? ''),
      EntryField(
        'url',
        'Credential URL',
        initial: item?.credentialUrl ?? '',
        keyboard: TextInputType.url,
      ),
      EntryField(
        'description',
        'Description',
        initial: item?.description ?? '',
        multiline: true,
      ),
    ],
  );

  if (result == null) return null;

  return Course(
    id: item?.id ?? _newId(),
    name: result['name'],
    provider: result['provider'],
    date: result['date'],
    credentialUrl: _nullIfBlank(result['url']),
    description: _nullIfBlank(result['description']),
    order: index ?? 0,
  );
}

Future<Language?> showLanguageEditor(
  BuildContext context, {
  Language? item,
  int? index,
}) async {
  final result = await showEntryDialog(
    context,
    title: item == null ? 'Add language' : 'Edit language',
    subtitle: 'Add languages and your level of confidence.',
    fields: [
      EntryField(
        'name',
        'Language',
        initial: item?.name ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. English',
      ),
      EntryField(
        'level',
        'Level',
        initial: item?.level ?? '',
        capitalization: TextCapitalization.words,
        required: true,
        hintText: 'e.g. Fluent / Native',
      ),
    ],
  );

  if (result == null) return null;

  return Language(
    id: item?.id ?? _newId(),
    name: result['name'],
    level: result['level'],
    order: index ?? 0,
  );
}
