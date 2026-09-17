
extension StrExt on String {
  String get firstLetter => isNotEmpty ? this[0] : '';

  String formatPhoneNumber(String phoneCode) {
    String trimmedPhoneNumber = trim();

    if (trimmedPhoneNumber.startsWith(phoneCode)) {
      return trimmedPhoneNumber;
    } else {
      return '$phoneCode $trimmedPhoneNumber';
    }
  }

  (String, String) get extractPhoneCodeAndNumber {
    List<String> parts = trim().split(RegExp(r'[\s-]+'));

    if (parts.length > 1) {
      String phoneCode = parts[0].trim().replaceAll("+", '');
      String phoneNumber = parts.sublist(1).join('').trim();
      return (phoneCode, phoneNumber);
    } else {
      return ('', trim());
    }
  }
}