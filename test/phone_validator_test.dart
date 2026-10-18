import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/phone_validator.dart';

void main() {
  group('PhoneValidator', () {
    test(
      'accepts exactly eight English digits and preserves a leading zero',
      () {
        expect(PhoneValidator.isValidLocalPart('05365521'), isTrue);
        expect(PhoneValidator.buildFullPhone('05365521'), '+966505365521');
      },
    );

    test('rejects invalid input', () {
      expect(PhoneValidator.isValidLocalPart('4536552'), isFalse);
      expect(PhoneValidator.isValidLocalPart('453655211'), isFalse);
      expect(PhoneValidator.isValidLocalPart('٤٥٣٦٥٥٢١'), isFalse);
      expect(PhoneValidator.isValidLocalPart('4536-521'), isFalse);
    });
  });
}
