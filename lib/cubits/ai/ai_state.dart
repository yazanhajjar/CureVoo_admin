import 'package:equatable/equatable.dart';

import '../../models/ai/ai_chat_message.dart';

enum AiStatus { initial, loading, ready, sending, failure }

class AiState extends Equatable {
  const AiState({
    this.status = AiStatus.initial,
    this.sessionId = '',
    this.diagnosisMessages = const <AiChatMessage>[],
    this.resistanceMessages = const <AiChatMessage>[],
    this.errorMessage,
  });

  final AiStatus status;
  final String sessionId;
  final List<AiChatMessage> diagnosisMessages;
  final List<AiChatMessage> resistanceMessages;
  final String? errorMessage;

  AiState copyWith({
    AiStatus? status,
    String? sessionId,
    List<AiChatMessage>? diagnosisMessages,
    List<AiChatMessage>? resistanceMessages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiState(
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      diagnosisMessages: diagnosisMessages ?? this.diagnosisMessages,
      resistanceMessages: resistanceMessages ?? this.resistanceMessages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, sessionId, diagnosisMessages, resistanceMessages, errorMessage];
}
