import 'package:equatable/equatable.dart';
import '../../domain/entities/resume.dart';
enum ResumesStatus { initial, loading, success, failure }
enum ResumeAction { none, creating, updating, deleting, duplicating }
class ResumesState extends Equatable {
 final ResumesStatus status; final List<Resume> resumes; final String? errorMessage; final ResumeAction action;
 const ResumesState({this.status=ResumesStatus.initial,this.resumes=const [],this.errorMessage,this.action=ResumeAction.none});
 ResumesState copyWith({ResumesStatus? status,List<Resume>? resumes,String? errorMessage,ResumeAction? action,bool clearError=false})=>ResumesState(status:status??this.status,resumes:resumes??this.resumes,errorMessage:clearError?null:errorMessage??this.errorMessage,action:action??this.action);
 @override List<Object?> get props=>[status,resumes,errorMessage,action];
}
