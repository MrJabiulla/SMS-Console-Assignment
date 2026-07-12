import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sms_console_assignment/core/api/api_client.dart';
import 'package:sms_console_assignment/core/constants/app_enums.dart';
import 'package:sms_console_assignment/core/storage/local_manager.dart';
import 'package:sms_console_assignment/features/sms/bloc/sms_bloc.dart';
import 'package:sms_console_assignment/features/sms/data/sms_mock_api.dart';
import 'package:sms_console_assignment/features/sms/data/sms_remote_data_source.dart';
import 'package:sms_console_assignment/features/sms/data/sms_repository.dart';

void main() {
  test('loads cost breakdown and masked message history', () async {
    final bloc = SmsBloc(_repository())..add(const SmsStarted());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<SmsState>(
          (state) =>
              state.status == SmsViewStatus.loaded &&
              state.messages.first.recipient.contains('*****'),
        ),
      ),
    );

    await bloc.close();
  });
}

SmsRepository _repository() {
  return SmsRepository(
    useMockApi: true,
    mockApi: SmsMockApi(),
    remoteDataSource: SmsRemoteDataSource(
      ApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: http.Client(),
        localManager: LocalManager(
          accessToken: 'test-token',
          tenantId: '00000000-0000-0000-0000-000000000000',
        ),
      ),
    ),
  );
}
