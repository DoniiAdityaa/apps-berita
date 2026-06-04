import 'dart:io';

import 'package:app_berita/model/firebase_error_log_model.dart';
import 'package:app_berita/model/user_model.dart';
import 'package:app_berita/utility/extensions/date_time_extensions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/constant.dart';
import '../config/service_locator.dart';
import '../config/user_preference.dart';

class FirebaseDatabaseSender {
  final PackageInfo _packageInfo = serviceLocator.get<PackageInfo>();
  final UserPreference _userPreference = serviceLocator.get<UserPreference>();
  final DatabaseReference _databaseReference = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: firebaseDatabaseUrl,
  ).ref();

  void sendDioExceptionLog({required DioException dioException}) async {
    String monthYear = DateTime.now().convert(format: "yyyy-MM");
    String date = DateTime.now().convert(format: "dd MMMM yyyy");
    String time = DateTime.now().convert(format: "HH:mm:ss");
    String path =
        dioException.requestOptions.baseUrl + dioException.requestOptions.path;
    String token = _userPreference.getToken() ?? "-";
    _userPreference.getUser();
    String type;
    String message;

    var deviceInfo = "";
    var appVersion = _packageInfo.version;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      deviceInfo = 'Android $release (SDK $sdkInt), $manufacturer $model';
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      deviceInfo = '$systemName $version, $name $model';
    }

    if (dioException.type == DioExceptionType.badResponse) {
      type = "BAD_RESPONSE";
      final errorResponse = dioException.response?.data as Map<String, dynamic>;
      message = errorResponse.toString();
      final FirebaseErrorLogModel firebaseErrorLogModel = FirebaseErrorLogModel(
        message: message,
        device: deviceInfo,
        path: path,
        date: date,
        token: token,
        user: {},
        appVersion: appVersion,
      );
      final String errorCode =
          dioException.response?.statusCode?.toString() ?? "-";
      await _databaseReference
          .child("Error Log")
          .child(type)
          .child(errorCode)
          .child(monthYear)
          .child(date)
          .child(time)
          .set(firebaseErrorLogModel.toJson());
    } else {
      type = "OTHER";
      message =
          "MESSAGE : ${dioException.message} , ERROR : ${dioException.error}, STACKTRACE : ${dioException.stackTrace}, TYPE : ${dioException.type}";
      final FirebaseErrorLogModel firebaseErrorLogModel = FirebaseErrorLogModel(
        message: message,
        device: deviceInfo,
        path: path,
        date: date,
        token: token,
        user: {},
        appVersion: appVersion,
      );
      await _databaseReference
          .child("Error Log")
          .child(type)
          .child(monthYear)
          .child(date)
          .child(time)
          .set(firebaseErrorLogModel.toJson());
    }
  }

  void sendErrorMessageLog({
    required String message,
    required String stackTrace,
  }) async {
    String monthYear = DateTime.now().convert(format: "yyyy-MM");
    String date = DateTime.now().convert(format: "dd MMMM yyyy");
    String time = DateTime.now().convert(format: "HH:mm:ss");
    String token = _userPreference.getToken() ?? "-";
    // ignore: unused_local_variable
    UserModel user = _userPreference.getUser();
    String type = "OTHER";

    var deviceInfo = "";
    var appVersion = _packageInfo.version;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      deviceInfo = 'Android $release (SDK $sdkInt), $manufacturer $model';
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      deviceInfo = '$systemName $version, $name $model';
    }

    final FirebaseErrorLogModel firebaseErrorLogModel = FirebaseErrorLogModel(
      message: message,
      device: deviceInfo,
      stackTrace: stackTrace,
      date: date,
      token: token,
      user: {},
      appVersion: appVersion,
    );
    await _databaseReference
        .child("Error Log")
        .child(type)
        .child(monthYear)
        .child(date)
        .child(time)
        .set(firebaseErrorLogModel.toJson());
  }

  void sendReceiptData({required String message}) async {
    String monthYear = DateTime.now().convert(format: "yyyy-MM");
    String date = DateTime.now().convert(format: "dd MMMM yyyy");
    String time = DateTime.now().convert(format: "HH:mm:ss");
    String token = _userPreference.getToken() ?? "-";
    _userPreference.getUser();
    String type = "RECEIPT-DATA";

    var deviceInfo = "";
    var appVersion = _packageInfo.version;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      deviceInfo = 'Android $release (SDK $sdkInt), $manufacturer $model';
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      deviceInfo = '$systemName $version, $name $model';
    }

    final FirebaseErrorLogModel firebaseErrorLogModel = FirebaseErrorLogModel(
      message: message,
      device: deviceInfo,
      stackTrace: null,
      date: date,
      token: token,
      user: {},
      appVersion: appVersion,
    );
    await _databaseReference
        .child("Error Log")
        .child(type)
        .child(monthYear)
        .child(date)
        .child(time)
        .set(firebaseErrorLogModel.toJson());
  }
}
