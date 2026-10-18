import 'package:jaycom_contacts/core/constants/app_constants.dart';

abstract final class PhoneValidator {
  static final RegExp _saudiLocalMobile = RegExp(r'^05[0-9]{8}$');

  static bool isValidLocalNumber(String value) =>
      _saudiLocalMobile.hasMatch(value);

  static String buildFullPhone(String localNumber) {
    if (!isValidLocalNumber(localNumber)) {
      throw const FormatException(
        'يجب أن يتكون الرقم من 10 أرقام إنجليزية ويبدأ بـ 05.',
      );
    }
    return '${AppConstants.saudiMobilePrefix}${localNumber.substring(2)}';
  }
}
