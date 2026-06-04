import 'package:app_berita/ui/color.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const String productionPackageName = "id.garda.mobile";
const String sandboxPackageName = "id.garda.mobile";
const String appId = "6478091723";

/// Network Config
const String baseUrlProduction = "https://newsapi.org/v2";
const String baseUrlSandbox = "https://newsapi.org/v2/";
const String baseSocketProduction = 'https://socket.can.co.id';
const String baseSocketSandbox = 'https://socket.can.co.id';
const String baseUrl = isProduction ? baseUrlProduction : baseUrlSandbox;
const String baseSocket = isProduction
    ? baseSocketProduction
    : baseSocketSandbox;
const String baseApi = "$baseUrl/api/v1";
const String baseImage = baseUrl;
const String firebaseSecondaryApp = "secondary";
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=$productionPackageName';
const String appStoreUrl = 'https://apps.apple.com/id/app/garda/id$appId';
const String deleteAccountUrl = "https://forms.gle/MAqxWapu3KqSE9eE7";
const String notificationChannelId = "id.garda.mobile";

/// is production
const bool isProduction = false;

/// firebase url
const String firebaseDatabaseUrl =
    "https://garda-a5ea2-default-rtdb.asia-southeast1.firebasedatabase.app/";

/// Int
const int otpVerificationDurationInSeconds = 30;
const int timeOutDuration = 30;
const int successScreenDuration = 3;
const double imageMaxHeight = 720;
const double imageMaxWidth = 720;

const int firebaseOtpVerificationDurationInSeconds = 120;
const int whatsAppOtpVerificationDurationInSeconds = 300;

enum EmptyStateType { trx, voucher, notification, assignment }

enum SecurityType { personal, monthly, event }

enum SelectGuardType {
  manual(translatedName: 'Pilih Guard'),
  recomendation(translatedName: 'Rekomendasi');

  final String translatedName;

  const SelectGuardType({required this.translatedName});
}

enum OfficerType {
  gold(translatedName: "Gold"),
  platinum(translatedName: "Platinum"),
  militer(translatedName: "Militer");

  final String translatedName;

  const OfficerType({required this.translatedName});
}

enum DatePickerType { day, range }

enum SnackBarPosition { top, bottom }

enum SortByArticle {
  latest(translatedName: "Terbaru", jsonValue: "latest"),
  one_day_ago(translatedName: "1 Hari yang lalu", jsonValue: "one_day_ago"),
  three_day_ago(translatedName: "3 Hari yang lalu", jsonValue: "three_day_ago"),
  one_week_ago(translatedName: "1 Minggu yang lalu", jsonValue: "one_week_ago");

  final String jsonValue;
  final String translatedName;

  const SortByArticle({required this.translatedName, required this.jsonValue});
}

SortByArticle? sortByArticleFromString(String? value) {
  return SortByArticle.values.firstWhereOrNull((e) => e.jsonValue == value);
}

enum SortByGuard {
  all(jsonValue: "ALL", translatedName: "Semua"),
  gold(
    jsonValue: "292a8c2d-0209-4bca-8e85-289efcdca8e2",
    translatedName: "Gold",
  ),
  platinum(
    jsonValue: "aff8e851-8b0b-4428-8b76-a122e484e96e",
    translatedName: "Platinum",
  ),
  rating(jsonValue: "RATING", translatedName: "Rating"),
  closest(jsonValue: "CLOSEST", translatedName: "Jarak Terdekat"),
  male(jsonValue: "MALE", translatedName: "Laki-laki"),
  female(jsonValue: "FEMALE", translatedName: "Perempuan");

  final String jsonValue;
  final String translatedName;

  const SortByGuard({required this.jsonValue, required this.translatedName});
}

SortByGuard? sortByGuardFromString(String? value) {
  return SortByGuard.values.firstWhereOrNull((e) => e.jsonValue == value);
}

enum TransactionStatus {
  waiting(
    jsonValue: "WAITING",
    translatedName: "Menunggu Konfirmasi Petugas",
    color: bgFillSecondary,
  ),
  pending(
    jsonValue: "PENDING",
    translatedName: "Tagihan Aktif",
    color: bgFillSecondary,
  ),
  cancelled(
    jsonValue: "CANCELLED",
    translatedName: "Dibatalkan",
    color: bgFillPrimary,
  ),
  expired(
    jsonValue: "EXPIRED",
    translatedName: "Kadaluarsa",
    color: bgButtonDangerDefault,
  ),
  paid(jsonValue: "PAID", translatedName: "Selesai", color: bgFillSuccess);

  final String jsonValue;
  final String translatedName;
  final Color color;

  const TransactionStatus({
    required this.jsonValue,
    required this.translatedName,
    required this.color,
  });
}

TransactionStatus? transactionStatusFromString(String? value) {
  return TransactionStatus.values.firstWhereOrNull((e) => e.jsonValue == value);
}

/*
{
      "PENDING": "Menunggu Konfirmasi Petugas",
      "UPCOMING": "Akan Datang",
      "ON_PROCESS": "Berlangsung",
      "FINISHED": "Terselesaikan",
      "CANCELLED": "Dibatalkan"
    }
*/

enum AssignmentHistoryStatus {
  pending(jsonValue: "PENDING", translatedName: "Menunggu"),
  upcoming(jsonValue: "UPCOMING", translatedName: "Akan Datang"),
  process(jsonValue: "ON_PROCESS", translatedName: "Berlangsung"),
  finished(jsonValue: "FINISHED", translatedName: "Terselesaikan"),
  cancelled(jsonValue: "CANCELLED", translatedName: "Dibatalkan");

  final String jsonValue;
  final String translatedName;

  const AssignmentHistoryStatus({
    required this.jsonValue,
    required this.translatedName,
  });
}

AssignmentHistoryStatus? assignmentHistoryStatusFromString(String? value) {
  return AssignmentHistoryStatus.values.firstWhereOrNull(
    (e) => e.jsonValue == value,
  );
}

enum WebsocketStatus {
  waiting(jsonValue: 'WAITING', translatedName: 'Menunggu'),
  approved(jsonValue: 'APPROVED', translatedName: 'Disetujui'),
  rejected(jsonValue: 'REJECTED', translatedName: 'Ditolak');

  final String jsonValue;
  final String translatedName;

  const WebsocketStatus({
    required this.jsonValue,
    required this.translatedName,
  });
}
