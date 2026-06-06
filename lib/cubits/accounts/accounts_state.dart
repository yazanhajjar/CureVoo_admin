import 'package:equatable/equatable.dart';

enum AccountsStatus { initial, submitting, success, failure }

class AccountsState extends Equatable {
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.message,
  });

  final AccountsStatus status;
  final String? message;

  AccountsState copyWith({
    AccountsStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return AccountsState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, message];
}
