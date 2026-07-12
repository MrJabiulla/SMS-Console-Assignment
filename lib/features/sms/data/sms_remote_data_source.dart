import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_result.dart';
import 'interface/sms_data_source_interface.dart';
import 'models/sms_models.dart';

class SmsRemoteDataSource implements ISmsDataSource {
  SmsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiResult<Map<String, dynamic>>> send(SmsSendRequest request) {
    return _apiClient.post(ApiEndpoints.sendSms, body: request.toJson());
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> costBreakdown({
    required DateTime from,
    required DateTime to,
  }) {
    return _apiClient.get(
      ApiEndpoints.costBreakdown,
      queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> messages({String? cursor}) {
    return _apiClient.get(
      ApiEndpoints.messages,
      queryParameters: {'cursor': ?cursor, 'limit': '50'},
    );
  }
}
