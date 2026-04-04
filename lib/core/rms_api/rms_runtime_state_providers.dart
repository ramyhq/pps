import 'package:flutter_riverpod/flutter_riverpod.dart';

final rmsRuntimeStateProvider =
    NotifierProvider<RmsRuntimeStateNotifier, RmsRuntimeState>(
      RmsRuntimeStateNotifier.new,
    );

class RmsRuntimeState {
  const RmsRuntimeState({
    required this.cookieHeader,
    required this.xsrfToken,
    required this.sessionId,
  });

  final String? cookieHeader;
  final String? xsrfToken;
  final String? sessionId;

  RmsRuntimeState copyWith({
    String? cookieHeader,
    String? xsrfToken,
    String? sessionId,
  }) {
    return RmsRuntimeState(
      cookieHeader: cookieHeader ?? this.cookieHeader,
      xsrfToken: xsrfToken ?? this.xsrfToken,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class RmsRuntimeStateNotifier extends Notifier<RmsRuntimeState> {
  @override
  RmsRuntimeState build() {
    return const RmsRuntimeState(
      cookieHeader: null,
      xsrfToken: null,
      sessionId: null,
    );
  }

  void setCookieHeader(String? cookieHeader) {
    state = state.copyWith(cookieHeader: cookieHeader);
  }

  void setXsrfToken(String? token) {
    state = state.copyWith(xsrfToken: token);
  }

  void setSessionId(String? sessionId) {
    state = state.copyWith(sessionId: sessionId);
  }

  void clear() {
    state = const RmsRuntimeState(
      cookieHeader: null,
      xsrfToken: null,
      sessionId: null,
    );
  }
}
