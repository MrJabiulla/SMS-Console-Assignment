import '../../../core/api/api_result.dart';
import 'interface/sms_data_source_interface.dart';
import 'models/sms_models.dart';
import 'sms_local_cache.dart';
import 'sms_mock_api.dart';

class SmsRepository {
  SmsRepository({
    required this.remoteDataSource,
    required this.mockApi,
    required this.useMockApi,
    this.localCache,
  });

  final ISmsDataSource remoteDataSource;
  final SmsMockApi mockApi;
  final bool useMockApi;
  final SmsLocalCache? localCache;

  Future<ApiResult<SmsSendResult>> send(SmsSendRequest request) async {
    if (useMockApi) {
      return ApiResult(data: await mockApi.send(request), statusCode: 200);
    }

    final response = await remoteDataSource.send(request);
    if (response.data != null && _isSuccess(response.statusCode)) {
      return ApiResult(
        data: SmsSendResult.fromJson(response.data!),
        statusCode: response.statusCode,
      );
    }

    return ApiResult(
      statusCode: response.statusCode,
      failure: response.failure,
    );
  }

  Future<ApiResult<CostBreakdown>> costBreakdown() async {
    if (useMockApi) {
      return ApiResult(data: await mockApi.costBreakdown(), statusCode: 200);
    }

    final now = DateTime.now().toUtc();
    final from = DateTime.utc(now.year, now.month);
    final response = await remoteDataSource.costBreakdown(from: from, to: now);
    if (response.data != null && _isSuccess(response.statusCode)) {
      final breakdown = CostBreakdown.fromJson(response.data!);
      await localCache?.saveCostBreakdown(breakdown);
      return ApiResult(data: breakdown, statusCode: response.statusCode);
    }

    final cached = localCache?.readCostBreakdown();
    if (cached != null) {
      return ApiResult(data: cached, statusCode: response.statusCode);
    }

    return ApiResult(
      statusCode: response.statusCode,
      failure: response.failure,
    );
  }

  Future<ApiResult<MessagePage>> messages({String? cursor}) async {
    if (useMockApi) {
      return ApiResult(
        data: await mockApi.messages(cursor: cursor),
        statusCode: 200,
      );
    }

    final response = await remoteDataSource.messages(cursor: cursor);
    if (response.data != null && _isSuccess(response.statusCode)) {
      final page = MessagePage.fromJson(response.data!);
      if (cursor == null) {
        await localCache?.saveFirstMessagePage(page);
      }
      return ApiResult(data: page, statusCode: response.statusCode);
    }

    if (cursor == null) {
      final cached = localCache?.readFirstMessagePage();
      if (cached != null) {
        return ApiResult(data: cached, statusCode: response.statusCode);
      }
    }

    return ApiResult(
      statusCode: response.statusCode,
      failure: response.failure,
    );
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
}
