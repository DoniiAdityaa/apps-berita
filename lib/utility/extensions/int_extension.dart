import 'package:intl/intl.dart';

extension IntExtension on int {
  String secondsToMmSsFormat() {
    int minutes = this ~/ 60;
    int remainingSeconds = this % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  String convertRupiah() {
    try {
      final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID');
      return formatCurrency.format(this);
    } catch (e) {
      return toString();
    }
  }
}
