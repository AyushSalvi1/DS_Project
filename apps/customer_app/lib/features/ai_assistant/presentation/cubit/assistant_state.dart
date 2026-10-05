import 'package:decoze_core/core.dart';
import 'package:equatable/equatable.dart';

sealed class AssistantState extends Equatable {
  const AssistantState();

  @override
  List<Object?> get props => [];
}

class AssistantInitial extends AssistantState {
  const AssistantInitial();
}

class AssistantLoaded extends AssistantState {
  final List<AssistantMessageEntity> messages;
  final List<String> suggestions;
  final bool isLoading;

  const AssistantLoaded({
    required this.messages,
    this.suggestions = const [],
    this.isLoading = false,
  });

  AssistantMessageEntity? get lastAssistantMessage {
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == AssistantRole.assistant) {
        return messages[i];
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [messages, suggestions, isLoading];
}

class AssistantCleared extends AssistantState {
  final List<String> suggestions;

  const AssistantCleared({this.suggestions = const []});

  @override
  List<Object?> get props => [suggestions];
}

class AssistantError extends AssistantState {
  final String message;
  const AssistantError(this.message);

  @override
  List<Object?> get props => [message];
}
