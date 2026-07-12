import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.useMockApi,
    required this.demoAccessToken,
    required this.demoTenantId,
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: dotenv.get('BASE_URL'),
      useMockApi: dotenv.getBool('USE_MOCK_API'),
      demoAccessToken: dotenv.get('DEMO_ACCESS_TOKEN'),
      demoTenantId: dotenv.get('DEMO_TENANT_ID'),
    );
  }

  final String apiBaseUrl;
  final bool useMockApi;
  final String demoAccessToken;
  final String demoTenantId;
}
