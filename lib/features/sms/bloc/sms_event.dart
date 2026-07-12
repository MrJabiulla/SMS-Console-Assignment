part of 'sms_bloc.dart';

sealed class SmsEvent extends Equatable {
  const SmsEvent();

  @override
  List<Object?> get props => [];
}

class SmsStarted extends SmsEvent {
  const SmsStarted();
}

class SmsRetryRequested extends SmsEvent {
  const SmsRetryRequested();
}

class SmsSendRequested extends SmsEvent {
  const SmsSendRequested({required this.to, required this.body});

  final String to;
  final String body;

  @override
  List<Object?> get props => [to, body];
}

class SmsHistoryNextPageRequested extends SmsEvent {
  const SmsHistoryNextPageRequested();
}
