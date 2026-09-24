import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_template/core/config/app_config.dart';
import 'package:app_template/core/network/dio_http_client.dart';
import 'package:app_template/core/network/http_client.dart';
import 'package:app_template/core/platform/platform_info.dart';
import 'package:app_template/core/storage/key_value_storage.dart';
import 'package:app_template/core/utils/logger.dart';
import 'package:app_template/features/counter/data/datasources/counter_local_datasource.dart';
import 'package:app_template/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:app_template/features/counter/domain/repositories/counter_repository.dart';
import 'package:app_template/features/counter/domain/usecases/get_counter.dart';
import 'package:app_template/features/counter/domain/usecases/increment_counter.dart';
import 'package:app_template/features/counter/presentation/state/counter_cubit.dart';
import 'package:app_template/platforms/platform_info/platform_info_impl.dart';
import 'package:app_template/platforms/storage/shared_preferences_storage.dart';

/// The global service-locator instance used by the app.
final GetIt sl = GetIt.instance;

/// Wires up all dependencies. Call once during bootstrap, before `runApp`.
///
/// Registration order follows the architecture: core singletons first, then the
/// feature data layer (datasource -> repository), and finally use cases and the
/// presentation Cubit that depend on them.
Future<void> initDi() async {
  // --- Core singletons -----------------------------------------------------
  sl.registerLazySingleton<Logger>(() => DefaultLogger());
  sl.registerLazySingleton<AppConfig>(() => const AppConfig());
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<KeyValueStorage>(
    () => SharedPreferencesStorage(prefs),
  );
  sl.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      Dio(
        BaseOptions(
          baseUrl: sl<AppConfig>().apiBaseUrl,
          connectTimeout: sl<AppConfig>().connectTimeout,
          receiveTimeout: sl<AppConfig>().receiveTimeout,
        ),
      ),
    ),
  );
  sl.registerLazySingleton<PlatformInfo>(() => const PlatformInfoImpl());

  // --- Feature: counter (data layer) --------------------------------------
  sl.registerLazySingleton<CounterLocalDataSource>(
    () => CounterLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<CounterRepository>(
    () => CounterRepositoryImpl(localDataSource: sl()),
  );

  // --- Feature: counter (domain + presentation) ---------------------------
  sl.registerLazySingleton<GetCounter>(
    () => GetCounter(repository: sl()),
  );
  sl.registerLazySingleton<IncrementCounter>(
    () => IncrementCounter(repository: sl()),
  );
  // A fresh Cubit is created per widget tree (factory, not singleton).
  sl.registerFactory<CounterCubit>(
    () => CounterCubit(
      getCounter: sl(),
      incrementCounter: sl(),
    ),
  );
}
