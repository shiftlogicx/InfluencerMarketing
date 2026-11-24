import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'phone_otp_auth_dialog.dart';

/// Backward-compatible wrapper ensuring all auth entry points invoke the new OTP-based login system
class AuthSsoDialog {
  static void show(
    BuildContext context,
    AppState appState, {
    VoidCallback? onCompleted,
    String? targetRole,
  }) {
    PhoneOtpAuthDialog.show(
      context,
      appState,
      onCompleted: onCompleted,
      targetRole: targetRole,
    );
  }
}
