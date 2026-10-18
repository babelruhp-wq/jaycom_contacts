import 'package:dio/dio.dart';
import 'package:jaycom_contacts/core/constants/api_constants.dart';
import 'package:jaycom_contacts/core/errors/app_exception.dart';
import 'package:jaycom_contacts/features/contacts/data/models/contact_model.dart';

abstract interface class ContactsRemoteDataSource {
  Future<List<ContactModel>> getContacts();
  Future<void> addContact({required int professionId, required String phone});
}

class ContactsRemoteDataSourceImpl implements ContactsRemoteDataSource {
  const ContactsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ContactModel>> getContacts() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.contacts,
      );
      final rawContacts =
          response.data?['contacts'] as List<dynamic>? ?? const [];
      return rawContacts
          .map((item) => ContactModel.fromJson(item as Map<String, dynamic>))
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
  Future<void> addContact({
    required int professionId,
    required String phone,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.contacts,
        data: {'professionId': professionId, 'phone': phone},
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
