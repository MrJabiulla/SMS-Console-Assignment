import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_enums.dart';
import '../../../core/constants/strings.dart';
import '../../../core/money/money_formatter.dart';
import '../../../shared/utils/snack_message.dart';
import '../../../shared/widgets/app_empty_view.dart';
import '../../../shared/widgets/app_error_view.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../bloc/sms_bloc.dart';
import 'widgets/cost_breakdown_card.dart';
import 'widgets/message_history_list.dart';
import 'widgets/sms_send_form.dart';

class SmsConsolePage extends StatelessWidget {
  const SmsConsolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SmsBloc, SmsState>(
      listenWhen: (previous, current) =>
          previous.lastSent != current.lastSent ||
          previous.failure != current.failure ||
          previous.isSending != current.isSending,
      listener: (context, state) {
        if (state.isSending) {
          Loader.show(context);
          return;
        }

        Loader.hide(context);

        final sent = state.lastSent;
        if (sent != null) {
          makeSnack(
            context,
            'SMS accepted by ${sent.provider} for ${MoneyFormatter.format(sent.cost)}',
            isSuccess: true,
          );
        } else if (state.failure != null && !state.isSending) {
          makeSnack(context, state.failure!.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(Strings.appTitle)),
        body: SafeArea(
          child: BlocBuilder<SmsBloc, SmsState>(
            builder: (context, state) {
              if (state.status == SmsViewStatus.loading ||
                  state.status == SmsViewStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == SmsViewStatus.failure) {
                return AppErrorView(
                  message:
                      state.failure?.message ?? Strings.couldNotLoadSmsData,
                  onRetry: () =>
                      context.read<SmsBloc>().add(const SmsRetryRequested()),
                );
              }

              return ResponsivePage(
                compactBuilder: (context, constraints) =>
                    _CompactSmsConsole(state: state),
                expandedBuilder: (context, constraints) =>
                    _DesktopSmsConsole(state: state),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CompactSmsConsole extends StatelessWidget {
  const _CompactSmsConsole({required this.state});

  final SmsState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('sms-console-compact-layout'),
      children: [
        SmsSendForm(isSending: state.isSending),
        const SizedBox(height: 20),
        SizedBox(height: 520, child: _Dashboard(state: state)),
      ],
    );
  }
}

class _DesktopSmsConsole extends StatelessWidget {
  const _DesktopSmsConsole({required this.state});

  final SmsState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('sms-console-desktop-layout'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: SmsSendForm(isSending: state.isSending),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(child: _Dashboard(state: state)),
      ],
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.state});

  final SmsState state;

  @override
  Widget build(BuildContext context) {
    final breakdown = state.breakdown;
    if (breakdown == null) {
      return const AppEmptyView(
        title: Strings.noBillingDataYet,
        message: Strings.noBillingDataMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CostBreakdownCard(breakdown: breakdown),
        const SizedBox(height: 16),
        Expanded(
          child: MessageHistoryList(
            messages: state.messages,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: () => context.read<SmsBloc>().add(
              const SmsHistoryNextPageRequested(),
            ),
          ),
        ),
      ],
    );
  }
}
