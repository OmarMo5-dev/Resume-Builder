import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart';
import '../../domain/entities/resume.dart';
import '../../domain/usecases/get_public_resume.dart';
import 'resume_preview_page.dart';

class PublicResumePage extends StatefulWidget {
  final String uid;
  final String resumeId;

  const PublicResumePage({super.key, required this.uid, required this.resumeId});

  @override
  State<PublicResumePage> createState() => _PublicResumePageState();
}

class _PublicResumePageState extends State<PublicResumePage> {
  // Created once so rebuilds never re-trigger the Firestore read.
  late final Future<Resume> _future =
      getIt<GetPublicResume>()(uid: widget.uid, resumeId: widget.resumeId);

  @override
  Widget build(BuildContext context) => FutureBuilder<Resume>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final resume = snapshot.data;
          if (snapshot.hasError || resume == null) {
            return const Scaffold(body: Center(child: Text('Resume not found')));
          }
          if (!resume.isPublic) {
            return const Scaffold(body: Center(child: Text('This resume is private')));
          }
          return ResumePreviewPage(resume: resume);
        },
      );
}
