import 'package:flutter_riverpod/flutter_riverpod.dart';

final rmsRuntimeStateProvider =
    NotifierProvider<RmsRuntimeStateNotifier, RmsRuntimeState>(
      RmsRuntimeStateNotifier.new,
    );

class RmsRuntimeState {
  const RmsRuntimeState({required this.cookieHeader, required this.xsrfToken});

  final String? cookieHeader;
  final String? xsrfToken;

  RmsRuntimeState copyWith({String? cookieHeader, String? xsrfToken}) {
    return RmsRuntimeState(
      cookieHeader: cookieHeader ?? this.cookieHeader,
      xsrfToken: xsrfToken ?? this.xsrfToken,
    );
  }
}

class RmsRuntimeStateNotifier extends Notifier<RmsRuntimeState> {
  @override
  RmsRuntimeState build() {
    return const RmsRuntimeState(cookieHeader: null, xsrfToken: null);
  }

  void setCookieHeader(String? cookieHeader) {
    state = state.copyWith(cookieHeader: cookieHeader);
  }

  void setXsrfToken(String? token) {
    state = state.copyWith(xsrfToken: token);
  }

  void clear() {
    state = const RmsRuntimeState(cookieHeader: null, xsrfToken: null);
  }
}
