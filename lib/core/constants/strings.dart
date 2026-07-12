class Strings {
  Strings._();

  // App
  static const String appTitle = 'SMS Console';

  // SMS
  static const String sendSms = 'Send SMS';
  static const String recipientPhone = 'Recipient phone';
  static const String recipientPhoneNumber = 'Recipient phone number';
  static const String message = 'Message';
  static const String smsMessageBody = 'SMS message body';
  static const String monthlyCost = 'Monthly cost';
  static const String noBillingDataYet = 'No billing data yet';
  static const String noBillingDataMessage =
      'Send your first SMS to see monthly cost and message history.';
  static const String noMessagesYet = 'No messages yet';
  static const String noMessagesMessage =
      'Sent messages will appear here with masked recipients.';
  static const String loading = 'Loading...';
  static const String loadMore = 'Load more';
  static const String sms = 'SMS';
  static const String segmentSuffix = 'segment(s)';

  // Error
  static const String retry = 'Retry';
  static const String couldNotLoadSmsData = 'Could not load SMS data.';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneFormatExample =
      'Use E.164 format, for example +4915112345678';
  static const String messageRequired = 'Message is required';
  static const String messageMaxLength =
      'Message must be 320 characters or less';
}
