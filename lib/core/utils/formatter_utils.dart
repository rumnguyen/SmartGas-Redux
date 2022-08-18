import 'package:intl/intl.dart';

class FormatterUtils {
  static String formatDistance(double distance) {
    NumberFormat formatter = NumberFormat("###.0");
    if (distance >= 1.0) {
      formatter.maximumFractionDigits = 1;
      return "${formatter.format(distance)}km";
    } else {
      formatter.maximumFractionDigits = 0;
      return "${formatter.format(distance * 1000)}m";
    }
  }

  static String formatNumber(double num, {bool isInteger = false}) {
    NumberFormat formatter = NumberFormat("###.0");
    formatter.maximumFractionDigits = 1;
    return formatter.format(num);
  }

  static String formatCurrency(int? price, {String currency = "VND"}) {
    NumberFormat formatter = NumberFormat("###,###.0");
    formatter.maximumFractionDigits = 0;
    formatter.maximumIntegerDigits = 3;
    return '${formatter.format(price ?? 0)} $currency';
  }

  static double calculatorSummary(int total, int reward, int gift, int subTax) {
    return (total - reward - gift) * (1 + subTax / 100);
  }

  static double calculatorTotalSummaryMoney({
    required int totalMoney,
    required int rewardPoint,
    required int totalGifts,
    required int totalSubTax,
  }) {
    return calculatorSummary(totalMoney, rewardPoint, totalGifts, totalSubTax);
  }
}
