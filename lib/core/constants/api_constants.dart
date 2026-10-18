abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://jaycomcontacts.runasp.net/',
  );
  static const contacts = 'Contacts';
  static const professions = 'Contacts/professions';
}
