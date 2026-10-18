import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jaycom_contacts/core/network/dio_client.dart';
import 'package:jaycom_contacts/core/router/app_router.dart';
import 'package:jaycom_contacts/features/auth/data/repositories/auth_session_repository_impl.dart';
import 'package:jaycom_contacts/features/auth/domain/repositories/auth_session_repository.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaycom_contacts/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:jaycom_contacts/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:jaycom_contacts/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:jaycom_contacts/features/professions/data/datasources/professions_remote_data_source.dart';
import 'package:jaycom_contacts/features/professions/data/repositories/professions_repository_impl.dart';
import 'package:jaycom_contacts/features/professions/domain/repositories/professions_repository.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<Dio>()) return;

  final preferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(preferences);
  getIt.registerLazySingleton<Dio>(createDioClient);

  getIt.registerLazySingleton<AuthSessionRepository>(
    () => AuthSessionRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<ProfessionsRemoteDataSource>(
    () => ProfessionsRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ContactsRemoteDataSource>(
    () => ContactsRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<ProfessionsRepository>(
    () => ProfessionsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(getIt()));
  getIt.registerLazySingleton<ProfessionsCubit>(
    () => ProfessionsCubit(getIt()),
  );
  getIt.registerLazySingleton<ContactsCubit>(() => ContactsCubit(getIt()));
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt()));
}
