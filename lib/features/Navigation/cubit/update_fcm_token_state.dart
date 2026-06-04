part of 'update_fcm_token_cubit.dart';

sealed class UpdateFcmTokenState extends Equatable {
  const UpdateFcmTokenState();

  @override
  List<Object> get props => [];
}

final class UpdateFcmTokenInitial extends UpdateFcmTokenState {}

final class UpdateFcmTokenStateLoading extends UpdateFcmTokenState {}

final class UpdateFcmTokenStateSuccess extends UpdateFcmTokenState {}

final class UpdateFcmTokenStateError extends UpdateFcmTokenState {
  final String message;

  const UpdateFcmTokenStateError({required this.message});
}
