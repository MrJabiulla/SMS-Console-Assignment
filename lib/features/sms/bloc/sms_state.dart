part of 'sms_bloc.dart';

class SmsState extends Equatable {
  const SmsState({
    required this.status,
    this.breakdown,
    this.messages = const [],
    this.nextCursor,
    this.failure,
    this.isSending = false,
    this.isLoadingMore = false,
    this.lastSent,
  });

  const SmsState.initial() : this(status: SmsViewStatus.initial);

  final SmsViewStatus status;
  final CostBreakdown? breakdown;
  final List<SmsMessage> messages;
  final String? nextCursor;
  final AppFailure? failure;
  final bool isSending;
  final bool isLoadingMore;
  final SmsSendResult? lastSent;

  bool get hasMore => nextCursor != null;

  SmsState copyWith({
    SmsViewStatus? status,
    CostBreakdown? breakdown,
    List<SmsMessage>? messages,
    String? nextCursor,
    AppFailure? failure,
    bool? isSending,
    bool? isLoadingMore,
    SmsSendResult? lastSent,
    bool keepCursor = false,
    bool clearFailure = false,
    bool clearLastSent = false,
  }) {
    return SmsState(
      status: status ?? this.status,
      breakdown: breakdown ?? this.breakdown,
      messages: messages ?? this.messages,
      nextCursor: keepCursor ? this.nextCursor : nextCursor,
      failure: clearFailure ? null : failure ?? this.failure,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      lastSent: clearLastSent ? null : lastSent ?? this.lastSent,
    );
  }

  @override
  List<Object?> get props => [
    status,
    breakdown,
    messages,
    nextCursor,
    failure,
    isSending,
    isLoadingMore,
    lastSent,
  ];
}
