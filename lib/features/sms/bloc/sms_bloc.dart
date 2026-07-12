import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_enums.dart';
import '../../../core/error/app_failure.dart';
import '../data/models/sms_models.dart';
import '../data/sms_repository.dart';

part 'sms_event.dart';
part 'sms_state.dart';

class SmsBloc extends Bloc<SmsEvent, SmsState> {
  SmsBloc(this._repository) : super(const SmsState.initial()) {
    on<SmsStarted>(_load);
    on<SmsRetryRequested>(_load);
    on<SmsSendRequested>(_send);
    on<SmsHistoryNextPageRequested>(_loadMore);
  }

  final SmsRepository _repository;

  Future<void> _load(SmsEvent event, Emitter<SmsState> emit) async {
    emit(state.copyWith(status: SmsViewStatus.loading, clearFailure: true));

    try {
      final breakdownResult = await _repository.costBreakdown();
      if (breakdownResult.data == null) {
        emit(
          state.copyWith(
            status: SmsViewStatus.failure,
            failure: _failureFromResult(breakdownResult.failure),
          ),
        );
        return;
      }

      final messagesResult = await _repository.messages();
      if (messagesResult.data == null) {
        emit(
          state.copyWith(
            status: SmsViewStatus.failure,
            failure: _failureFromResult(messagesResult.failure),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: SmsViewStatus.loaded,
          breakdown: breakdownResult.data,
          messages: messagesResult.data!.items,
          nextCursor: messagesResult.data!.nextCursor,
          clearFailure: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SmsViewStatus.failure,
          failure: _failureFromResult(null),
        ),
      );
    }
  }

  Future<void> _send(SmsSendRequested event, Emitter<SmsState> emit) async {
    emit(
      state.copyWith(
        isSending: true,
        clearFailure: true,
        clearLastSent: true,
        keepCursor: true,
      ),
    );

    try {
      final result = await _repository.send(
        SmsSendRequest(
          to: event.to,
          body: event.body,
          referenceId: 'sms-${DateTime.now().microsecondsSinceEpoch}',
        ),
      );

      if (result.data == null) {
        emit(
          state.copyWith(
            failure: _failureFromResult(result.failure),
            isSending: false,
            keepCursor: true,
          ),
        );
        return;
      }

      final breakdownResult = await _repository.costBreakdown();
      final messagesResult = await _repository.messages();

      emit(
        state.copyWith(
          status: SmsViewStatus.loaded,
          isSending: false,
          lastSent: result.data,
          breakdown: breakdownResult.data ?? state.breakdown,
          messages: messagesResult.data?.items ?? state.messages,
          nextCursor: messagesResult.data?.nextCursor ?? state.nextCursor,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          failure: _failureFromResult(null),
          isSending: false,
          keepCursor: true,
        ),
      );
    }
  }

  Future<void> _loadMore(
    SmsHistoryNextPageRequested event,
    Emitter<SmsState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(
      state.copyWith(isLoadingMore: true, clearFailure: true, keepCursor: true),
    );

    try {
      final result = await _repository.messages(cursor: state.nextCursor);
      if (result.data == null) {
        emit(
          state.copyWith(
            failure: _failureFromResult(result.failure),
            isLoadingMore: false,
            keepCursor: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          messages: [...state.messages, ...result.data!.items],
          nextCursor: result.data!.nextCursor,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          failure: _failureFromResult(null),
          isLoadingMore: false,
          keepCursor: true,
        ),
      );
    }
  }

  AppFailure _failureFromResult(AppFailure? failure) {
    return failure ??
        const AppFailure(
          message: 'Something went wrong. Please try again.',
          code: 'unknown_error',
        );
  }
}
