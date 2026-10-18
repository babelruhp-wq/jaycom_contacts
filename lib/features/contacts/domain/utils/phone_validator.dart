import 'package:jaycom_contacts/core/constants/app_constants.dart';

abstract final class PhoneValidator {
  static final RegExp _eightEnglishDigits = RegExp(r'^[0-9]{8}$');

  static bool isValidLocalPart(String value) =>
      _eightEnglishDigits.hasMatch(value);

  static String buildFullPhone(String localPart) {
    if (!isValidLocalPart(localPart)) {
      throw const FormatException('يجب أن يتكون الرقم من 8 أرقام إنجليزية.');
    }
    return '${AppConstants.saudiMobilePrefix}$localPart';
  }
}
