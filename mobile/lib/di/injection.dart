import 'package:get_it/get_it.dart';
import '../config/constants.dart';
import '../core/network/api_client.dart';
import '../data/datasources/local/shared_prefs_local_storage.dart';
import '../data/datasources/remote/auth_remote_source.dart';
import '../data/datasources/remote/pharmacy_remote_source.dart';
import '../data/datasources/remote/ar_remote_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/ar/ar_bloc.dart';
import '../data/datasources/remote/medication_remote_source.dart';
import '../presentation/bloc/medication/medication_bloc.dart';

final getIt = GetIt.instance;


Future<void> configureDependencies() async {
  // Local storage
  getIt.registerLazySingleton<LocalStorage>(() => SharedPrefsLocalStorage());

  // API client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: AppConstants.apiBaseUrl,
      localStorage: getIt<LocalStorage>(),
    ),
  );

  // Remote data sources
  getIt.registerLazySingleton<AuthRemoteSource>(
    () => AuthRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PharmacyRemoteSource>(
    () => PharmacyRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ARRemoteSource>(
    () => ARRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      remoteSource: getIt<AuthRemoteSource>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );

  // BLoCs — factory so each widget subtree gets a fresh instance
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(repository: getIt<AuthRepositoryImpl>()),
  );

  // AR BLoC
  getIt.registerFactory<ARScanBloc>(
    () => ARScanBloc(remoteSource: getIt<ARRemoteSource>()),
  );

  // Medication
  getIt.registerLazySingleton<MedicationRemoteSource>(
    () => MedicationRemoteSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerFactory<MedicationBloc>(
    () => MedicationBloc(remoteSource: getIt<MedicationRemoteSource>()),
  );
}
