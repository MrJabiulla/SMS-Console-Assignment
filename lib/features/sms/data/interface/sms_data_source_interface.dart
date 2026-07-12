import '../../../../core/api/api_result.dart';
import '../models/sms_models.dart';

abstract class ISmsDataSource {
  Future<ApiResult<Map<String, dynamic>>> send(SmsSendRequest request);

  Future<ApiResult<Map<String, dynamic>>> costBreakdown({
    required DateTime from,
    required DateTime to,
  });

  Future<ApiResult<Map<String, dynamic>>> messages({String? cursor});
}
