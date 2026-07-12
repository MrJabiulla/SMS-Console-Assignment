import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/strings.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../bloc/sms_bloc.dart';

class SmsSendForm extends StatefulWidget {
  const SmsSendForm({required this.isSending, super.key});

  final bool isSending;

  @override
  State<SmsSendForm> createState() => _SmsSendFormState();
}

class _SmsSendFormState extends State<SmsSendForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SmsBloc, SmsState>(
      listenWhen: (previous, current) => previous.lastSent != current.lastSent,
      listener: (context, state) {
        if (state.lastSent == null) return;
        _phoneController.clear();
        _messageController.clear();
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Strings.sendSms,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  label: Strings.recipientPhone,
                  semanticLabel: Strings.recipientPhoneNumber,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _messageController,
                  label: Strings.message,
                  semanticLabel: Strings.smsMessageBody,
                  maxLines: 5,
                  validator: Validators.message,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: Strings.sendSms,
                  isLoading: widget.isSending,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<SmsBloc>().add(
      SmsSendRequested(
        to: _phoneController.text.trim(),
        body: _messageController.text.trim(),
      ),
    );
  }
}
