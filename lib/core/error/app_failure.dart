import 'package:equatable/equatable.dart';

class AppFailure extends Equatable {
  const AppFailure({required this.message, this.code, this.retryAfter});

  final String message;
  final String? code;
  final Duration? retryAfter;

  @override
  List<Object?> get props => [message, code, retryAfter];
}
