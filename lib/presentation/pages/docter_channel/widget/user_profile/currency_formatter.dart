import 'dart:math' as math;

class CurrencyFormatter {
  /// Formats currency with commas for thousands separator
  static String format(int amount) {
    final String amountStr = amount.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }

  /// Formats currency with commas for double values
  static String formatDouble(double amount, {int decimalPlaces = 2}) {
    final String formatted = amount.toStringAsFixed(decimalPlaces);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInteger = integerPart.replaceAllMapped(reg, (Match match) => '${match[1]},');
    
    if (decimalPart.isEmpty || decimalPart == '00') {
      return formattedInteger;
    }
    
    return '$formattedInteger.$decimalPart';
  }

  /// Formats currency with LKR prefix
  static String formatWithCurrency(int amount, {String currency = 'LKR'}) {
    return '$currency ${format(amount)}';
  }

  /// Formats currency with LKR prefix for double values
  static String formatDoubleWithCurrency(double amount, {String currency = 'LKR', int decimalPlaces = 2}) {
    return '$currency ${formatDouble(amount, decimalPlaces: decimalPlaces)}';
  }

  /// Parses formatted currency string back to int
  static int? parseFormatted(String formattedAmount) {
    try {
      // Remove currency symbols and commas
      final cleanString = formattedAmount
          .replaceAll(RegExp(r'[^\d.]'), '')
          .replaceAll(',', '');
      
      if (cleanString.isEmpty) return null;
      
      final double? parsed = double.tryParse(cleanString);
      return parsed?.round();
    } catch (e) {
      return null;
    }
  }

  /// Converts amount to readable format (K for thousands, M for millions)
  static String formatCompact(int amount) {
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      return '${formatDouble(millions, decimalPlaces: 1)}M';
    } else if (amount >= 1000) {
      final thousands = amount / 1000;
      return '${formatDouble(thousands, decimalPlaces: 1)}K';
    } else {
      return amount.toString();
    }
  }

  /// Validates if a string is a valid currency format
  static bool isValidCurrency(String value) {
    try {
      final cleanString = value.replaceAll(RegExp(r'[^\d.]'), '');
      if (cleanString.isEmpty) return false;
      
      final double? parsed = double.tryParse(cleanString);
      return parsed != null && parsed >= 0;
    } catch (e) {
      return false;
    }
  }

  /// Formats amount with appropriate suffix and currency
  static String formatCompactWithCurrency(int amount, {String currency = 'LKR'}) {
    return '$currency ${formatCompact(amount)}';
  }

  /// Removes all formatting and returns clean number string
  static String cleanFormat(String formattedAmount) {
    return formattedAmount
        .replaceAll(RegExp(r'[^\d.]'), '')
        .replaceAll(',', '');
  }
}