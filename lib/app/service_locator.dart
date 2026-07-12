import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../core/api/api_client.dart';
import '../core/storage/local_manager.dart';
import '../features/sms/bloc/sms_bloc.dart';
import '../features/sms/data/interface/sms_data_source_interface.dart';
import '../features/sms/data/sms_local_cache.dart';
import '../features/sms/data/sms_mock_api.dart';
import '../features/sms/data/sms_remote_data_source.dart';
import '../features/sms/data/sms_repository.dart';
import 'app_config.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await Hive.initFlutter();

  final config = AppConfig.fromEnvironment();
  final localManager = await LocalManager.create(
    fallbackAccessToken: config.demoAccessToken,
    fallbackTenantId: config.demoTenantId,
  );
  final smsCache = await SmsLocalCache.create();

  sl.registerLazySingleton(() => config);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => localManager);
  sl.registerLazySingleton(() => smsCache);

  // Core
  sl.registerLazySingleton(
    () => ApiClient(
      baseUrl: config.apiBaseUrl,
      httpClient: sl(),
      localManager: sl(),
    ),
  );

  // SMS
  sl.registerLazySingleton<ISmsDataSource>(() => SmsRemoteDataSource(sl()));
  sl.registerLazySingleton(() => SmsMockApi());
  sl.registerLazySingleton(
    () => SmsRepository(
      remoteDataSource: sl(),
      mockApi: sl(),
      localCache: sl(),
      useMockApi: config.useMockApi,
    ),
  );
  sl.registerFactory(() => SmsBloc(sl()));
}
