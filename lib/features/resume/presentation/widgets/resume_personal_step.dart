import 'package:flutter/material.dart';

import '../widgets/editor_text_field.dart';

class ResumePersonalStep extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController job;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController location;
  final TextEditingController linkedin;
  final TextEditingController github;
  final TextEditingController website;
  final VoidCallback onChanged;

  const ResumePersonalStep({
    super.key,
    required this.name,
    required this.job,
    required this.email,
    required this.phone,
    required this.location,
    required this.linkedin,
    required this.github,
    required this.website,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditorTextField(
          controller: name,
          label: 'Full name',
          prefixIcon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.words,
          required: true,
          hintText: 'Your full name',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: job,
          label: 'Target job title',
          prefixIcon: Icons.work_outline_rounded,
          textCapitalization: TextCapitalization.words,
          required: true,
          hintText: 'e.g. Flutter Developer',
          helperText: 'Use the title of the role you want.',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: email,
          label: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          required: true,
          hintText: 'name@example.com',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: phone,
          label: 'Phone',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          hintText: '+20 ...',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: location,
          label: 'Location',
          prefixIcon: Icons.location_on_outlined,
          textCapitalization: TextCapitalization.words,
          hintText: 'Cairo, Egypt',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: linkedin,
          label: 'LinkedIn',
          prefixIcon: Icons.business_center_outlined,
          keyboardType: TextInputType.url,
          hintText: 'linkedin.com/in/...',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: github,
          label: 'GitHub',
          prefixIcon: Icons.code_outlined,
          keyboardType: TextInputType.url,
          hintText: 'github.com/...',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: website,
          label: 'Website / Portfolio',
          prefixIcon: Icons.link_outlined,
          keyboardType: TextInputType.url,
          hintText: 'yourwebsite.com',
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
