import 'package:intl/intl.dart';

class FormatterUtils {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('HH:mm - dd/MM/yyyy').format(date);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Chào buổi sáng';
    if (hour >= 12 && hour < 18) return 'Chào buổi chiều';
    return 'Chào';
  }
}
