class ApiEndpoints {
  const ApiEndpoints._();

  // SMS Endpoints
  static const String sendSms = '/api/v1/sms/send';
  static const String costBreakdown = '/api/v1/sms/cost/breakdown';
  static const String messages = '/api/v1/sms/messages';

  // Auth Endpoints
  static const String refreshToken = '/api/v1/auth/refresh';
}
