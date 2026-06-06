import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/ai/ai_chat_message.dart';
import '../../repos/ai_repo.dart';
import '../../repos/api_client.dart';
import 'ai_state.dart';

class AiCubit extends Cubit<AiState> {
  AiCubit(this._repo) : super(const AiState());

  final AiRepo _repo;

  void initSession(String sessionId) {
    emit(state.copyWith(status: AiStatus.ready, sessionId: sessionId, clearError: true));
  }

  Future<void> startDiagnosis() async {
    if (state.sessionId.isEmpty) return;
    emit(state.copyWith(status: AiStatus.loading, clearError: true));
    try {
      final reply = await _repo.startDiagnosis(sessionId: state.sessionId);
      final updated = List<AiChatMessage>.from(state.diagnosisMessages)
        ..add(AiChatMessage(sender: 'bot', text: reply));
      emit(state.copyWith(status: AiStatus.ready, diagnosisMessages: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AiStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> sendDiagnosis(String message) async {
    if (state.sessionId.isEmpty || message.trim().isEmpty) return;
    final withUser = List<AiChatMessage>.from(state.diagnosisMessages)
      ..add(AiChatMessage(sender: 'you', text: message));
    emit(state.copyWith(status: AiStatus.sending, diagnosisMessages: withUser, clearError: true));
    try {
      final reply = await _repo.sendDiagnosisMessage(sessionId: state.sessionId, message: message);
      final updated = List<AiChatMessage>.from(withUser)
        ..add(AiChatMessage(sender: 'bot', text: reply));
      emit(state.copyWith(status: AiStatus.ready, diagnosisMessages: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AiStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> startResistance() async {
    if (state.sessionId.isEmpty) return;
    emit(state.copyWith(status: AiStatus.loading, clearError: true));
    try {
      final reply = await _repo.startResistance(sessionId: state.sessionId);
      final updated = List<AiChatMessage>.from(state.resistanceMessages)
        ..add(AiChatMessage(sender: 'bot', text: reply));
      emit(state.copyWith(status: AiStatus.ready, resistanceMessages: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AiStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> sendResistance(String message) async {
    if (state.sessionId.isEmpty || message.trim().isEmpty) return;
    final withUser = List<AiChatMessage>.from(state.resistanceMessages)
      ..add(AiChatMessage(sender: 'you', text: message));
    emit(state.copyWith(status: AiStatus.sending, resistanceMessages: withUser, clearError: true));
    try {
      final reply = await _repo.sendResistanceMessage(sessionId: state.sessionId, message: message);
      final updated = List<AiChatMessage>.from(withUser)
        ..add(AiChatMessage(sender: 'bot', text: reply));
      emit(state.copyWith(status: AiStatus.ready, resistanceMessages: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AiStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> sendDiagnosisImage(String imageReference) async {
    if (state.sessionId.isEmpty || imageReference.trim().isEmpty) return;
    final withUser = List<AiChatMessage>.from(state.diagnosisMessages)
      ..add(AiChatMessage(sender: 'you', text: '[image] $imageReference'));
    emit(state.copyWith(status: AiStatus.sending, diagnosisMessages: withUser, clearError: true));
    try {
      final reply = await _repo.sendDiagnosisImage(
        sessionId: state.sessionId,
        imageReference: imageReference,
      );
      final updated = List<AiChatMessage>.from(withUser)
        ..add(AiChatMessage(sender: 'bot', text: reply));
      emit(state.copyWith(status: AiStatus.ready, diagnosisMessages: updated));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AiStatus.failure, errorMessage: e.message));
    }
  }
}
