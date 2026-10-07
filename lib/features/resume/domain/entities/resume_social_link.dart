import 'package:equatable/equatable.dart';

class ResumeSocialLink extends Equatable {
  final String id;
  final String platform;
  final String url;

  const ResumeSocialLink({
    required this.id,
    required this.platform,
    required this.url,
  });

  @override
  List<Object?> get props => [id, platform, url];
}
