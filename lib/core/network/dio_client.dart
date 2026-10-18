import 'package:dio/dio.dart';
import 'package:jaycom_contacts/core/constants/api_constants.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
  return dio;
}
