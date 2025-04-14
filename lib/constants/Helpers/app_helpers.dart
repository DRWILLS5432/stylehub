String formatPrice(dynamic price, {String currencySymbol = '\$', int decimalDigits = 2}) {
  if (price == null || price.toString().isEmpty) return '$currencySymbol 0.00';

  final amount = (price is num) ? price : (num.tryParse(price.toString())) ?? 0;
  final fixed = amount.toStringAsFixed(decimalDigits);

  // Simplified formatting without regex
  final parts = fixed.split('.');
  String integerPart = parts[0];
  final decimalPart = parts.length > 1 ? parts[1] : '00';

  // Add thousands separators
  final buffer = StringBuffer();
  for (int i = 0; i < integerPart.length; i++) {
    if (i > 0 && (integerPart.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(integerPart[i]);
  }

  return '$currencySymbol${buffer.toString()}.$decimalPart';
}
