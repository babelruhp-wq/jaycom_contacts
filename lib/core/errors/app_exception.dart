import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  factory AppException.fromDio(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return const AppException('انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.');
    }
    if (exception.type == DioExceptionType.connectionError) {
      return const AppException(
        'تعذر الاتصال بالخادم. تحقق من الإنترنت ثم حاول مرة أخرى.',
      );
    }

    final statusCode = exception.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return const AppException('يوجد عطل مؤقت في الخادم. حاول لاحقًا.');
    }
    if (statusCode == 400 || statusCode == 422) {
      return const AppException(
        'البيانات المدخلة غير مقبولة. راجعها وحاول مجددًا.',
      );
    }
    if (statusCode == 404) {
      return const AppException('الخدمة المطلوبة غير متاحة حاليًا.');
    }
    return const AppException('تعذر إكمال الطلب. حاول مرة أخرى.');
  }

  @override
  String toString() => message;
}

String readableError(Object error) {
  if (error is AppException) return error.message;
  if (error is DioException) return AppException.fromDio(error).message;
  return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
}
