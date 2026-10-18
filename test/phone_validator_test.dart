import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/phone_validator.dart';

void main() {
  group('PhoneValidator', () {
    test(
      'accepts a ten-digit local mobile and converts it to international form',
      () {
        expect(PhoneValidator.isValidLocalNumber('0545365521'), isTrue);
        expect(PhoneValidator.buildFullPhone('0545365521'), '+966545365521');
      },
    );

    test('rejects invalid input', () {
      expect(PhoneValidator.isValidLocalNumber('054536552'), isFalse);
      expect(PhoneValidator.isValidLocalNumber('05453655211'), isFalse);
      expect(PhoneValidator.isValidLocalNumber('5545365521'), isFalse);
      expect(PhoneValidator.isValidLocalNumber('0645365521'), isFalse);
      expect(PhoneValidator.isValidLocalNumber('٠٥٤٥٣٦٥٥٢١'), isFalse);
      expect(PhoneValidator.isValidLocalNumber('054-365521'), isFalse);
    });
  });
}
