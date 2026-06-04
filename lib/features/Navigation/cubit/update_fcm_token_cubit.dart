import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

part 'update_fcm_token_state.dart';

class UpdateFcmTokenCubit extends Cubit<UpdateFcmTokenState> {
  UpdateFcmTokenCubit() : super(UpdateFcmTokenInitial());

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> updateFcmToken() async {
    try {
      emit(UpdateFcmTokenStateLoading());

      await _messaging.requestPermission();

      String? fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $fcmToken');

      // TODO: kirim ke backend kalau sudah ada API-nya

      emit(UpdateFcmTokenStateSuccess());
    } catch (e) {
      emit(UpdateFcmTokenStateError(message: e.toString()));
    }
  }
}
