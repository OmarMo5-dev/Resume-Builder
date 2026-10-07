import 'package:equatable/equatable.dart';
import '../../domain/entities/resume.dart';

enum EditorStatus { initial, saving, saved, exporting, failure }

class ResumeEditorState extends Equatable {
  final Resume resume;
  final EditorStatus status;
  final bool dirty;
  final String? error;

  const ResumeEditorState({
    required this.resume,
    this.status = EditorStatus.initial,
    this.dirty = false,
    this.error,
  });

  ResumeEditorState copyWith({
    Resume? resume,
    EditorStatus? status,
    bool? dirty,
    String? error,
    bool clearError = false,
  }) => ResumeEditorState(
        resume: resume ?? this.resume,
        status: status ?? this.status,
        dirty: dirty ?? this.dirty,
        error: clearError ? null : error ?? this.error,
      );

  @override
  List<Object?> get props => [resume, status, dirty, error];
}
