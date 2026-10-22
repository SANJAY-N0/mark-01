/// Returns an error message for a user-facing phone field, or null if valid.
String? validatePhoneNumber(String? input) {
  final value = input?.trim() ?? '';
  if (value.isEmpty) {
    return 'Please enter a phone number.';
  }
  if (!RegExp(r'^\+?[0-9\s\-()]+$').hasMatch(value)) {
    return 'Use only numbers. A + sign is allowed at the start.';
  }
  final digitCount = value.replaceAll(RegExp(r'\D'), '').length;
  if (digitCount < 7 || digitCount > 15) {
    return 'This number does not look complete. Please check it.';
  }
  return null;
}

/// Strips spaces, dashes and brackets so the dialler receives a clean number.
/// Keeps a leading + for international numbers.
String toDialNumber(String input) {
  final trimmed = input.trim();
  final hasPlus = trimmed.startsWith('+');
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  return '${hasPlus ? '+' : ''}$digits';
}
