import 'package:dio/dio.dart';
import 'package:jaycom_contacts/core/constants/api_constants.dart';
import 'package:jaycom_contacts/core/errors/app_exception.dart';
import 'package:jaycom_contacts/features/professions/data/models/profession_model.dart';

abstract interface class ProfessionsRemoteDataSource {
  Future<List<ProfessionModel>> getProfessions();
  Future<void> addProfession(String name);
}

class ProfessionsRemoteDataSourceImpl implements ProfessionsRemoteDataSource {
  const ProfessionsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ProfessionModel>> getProfessions() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiConstants.professions);
      final data = response.data ?? const <dynamic>[];
      return data
          .map((item) => ProfessionModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    } on FormatException {
      throw const AppException('استجاب الخادم ببيانات غير صالحة.');
    } on TypeError {
      throw const AppException('استجاب الخادم ببيانات غير صالحة.');
    }
  }

  @override
  Future<void> addProfession(String name) async {
    try {
      await _dio.post<void>(
        ApiConstants.professions,
        data: {'name': name},
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 15),
        ),
      );
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }
}
