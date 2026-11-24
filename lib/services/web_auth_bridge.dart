// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class GoogleAuthResult {
  final bool isSuccess;
  final String email;
  final String displayName;
  final String photoUrl;
  final String uid;
  final String? errorMessage;

  GoogleAuthResult({
    required this.isSuccess,
    this.email = "",
    this.displayName = "",
    this.photoUrl = "",
    this.uid = "",
    this.errorMessage,
  });
}

class GeoLocationResult {
  final bool isSuccess;
  final double latitude;
  final double longitude;
  final String? errorMessage;

  GeoLocationResult({
    required this.isSuccess,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.errorMessage,
  });
}

class PhoneOtpSendResult {
  final bool isSuccess;
  final String? errorMessage;
  final String phoneNumber;
  final String? sessionOtp;

  PhoneOtpSendResult({
    required this.isSuccess,
    this.errorMessage,
    this.phoneNumber = "",
    this.sessionOtp,
  });
}

class PhoneOtpVerifyResult {
  final bool isSuccess;
  final String? uid;
  final String? phoneNumber;
  final String? errorMessage;

  PhoneOtpVerifyResult({
    required this.isSuccess,
    this.uid,
    this.phoneNumber,
    this.errorMessage,
  });
}

class WebAuthBridge {
  static Future<GoogleAuthResult> triggerGoogleSignIn() async {
    if (!kIsWeb) {
      return GoogleAuthResult(isSuccess: false, errorMessage: "Not running on Web platform.");
    }

    final completer = Completer<GoogleAuthResult>();
    final callbackName = "googleAuthCb_${DateTime.now().millisecondsSinceEpoch}";

    js.context[callbackName] = (String jsonStr) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        if (data['status'] == 'success') {
          completer.complete(
            GoogleAuthResult(
              isSuccess: true,
              email: data['email'] ?? "",
              displayName: data['displayName'] ?? "",
              photoUrl: data['photoURL'] ?? "",
              uid: data['uid'] ?? "",
            ),
          );
        } else {
          completer.complete(
            GoogleAuthResult(
              isSuccess: false,
              errorMessage: data['message'] ?? "Google SSO window was closed or cancelled.",
            ),
          );
        }
      } catch (e) {
        completer.complete(
          GoogleAuthResult(isSuccess: false, errorMessage: e.toString()),
        );
      } finally {
        js.context.deleteProperty(callbackName);
      }
    };

    try {
      js.context.callMethod('triggerGoogleSSO', [callbackName]);
    } catch (e) {
      completer.complete(
        GoogleAuthResult(isSuccess: false, errorMessage: "Failed to invoke Google SSO: $e"),
      );
    }

    return completer.future;
  }

  static Future<GeoLocationResult> getCurrentCoordinates() async {
    if (!kIsWeb) {
      return GeoLocationResult(isSuccess: false, errorMessage: "Not running on Web platform.");
    }

    final completer = Completer<GeoLocationResult>();
    final callbackName = "geoCb_${DateTime.now().millisecondsSinceEpoch}";

    js.context[callbackName] = (String jsonStr) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        if (data['status'] == 'success') {
          final lat = double.tryParse(data['latitude'].toString()) ?? 0.0;
          final lng = double.tryParse(data['longitude'].toString()) ?? 0.0;
          completer.complete(
            GeoLocationResult(isSuccess: true, latitude: lat, longitude: lng),
          );
        } else {
          completer.complete(
            GeoLocationResult(
              isSuccess: false,
              errorMessage: data['message'] ?? "Geolocation permission was denied.",
            ),
          );
        }
      } catch (e) {
        completer.complete(
          GeoLocationResult(isSuccess: false, errorMessage: e.toString()),
        );
      } finally {
        js.context.deleteProperty(callbackName);
      }
    };

    try {
      js.context.callMethod('getCurrentGeolocation', [callbackName]);
    } catch (e) {
      completer.complete(
        GeoLocationResult(isSuccess: false, errorMessage: "Failed to request geolocation: $e"),
      );
    }

    return completer.future;
  }

  // Real Firebase Phone Auth SMS
  static Future<PhoneOtpSendResult> sendPhoneOtp(String phoneNumber) async {
    if (!kIsWeb) {
      return PhoneOtpSendResult(isSuccess: false, errorMessage: "Not running on Web platform.");
    }

    final completer = Completer<PhoneOtpSendResult>();
    final callbackName = "sendPhoneOtpCb_${DateTime.now().millisecondsSinceEpoch}";

    js.context[callbackName] = (String jsonStr) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        if (data['status'] == 'success') {
          completer.complete(
            PhoneOtpSendResult(
              isSuccess: true,
              phoneNumber: data['phoneNumber'] ?? phoneNumber,
              sessionOtp: data['sessionOtp'],
            ),
          );
        } else {
          completer.complete(
            PhoneOtpSendResult(
              isSuccess: false,
              errorMessage: data['message'] ?? data['code'] ?? "Failed to dispatch SMS code.",
            ),
          );
        }
      } catch (e) {
        completer.complete(PhoneOtpSendResult(isSuccess: false, errorMessage: e.toString()));
      } finally {
        js.context.deleteProperty(callbackName);
      }
    };

    try {
      js.context.callMethod('sendFirebasePhoneSms', [phoneNumber, callbackName]);
    } catch (e) {
      completer.complete(PhoneOtpSendResult(isSuccess: false, errorMessage: e.toString()));
    }

    return completer.future;
  }

  // Real Firebase Phone Auth Verification
  static Future<PhoneOtpVerifyResult> verifyPhoneOtp(String otpCode) async {
    if (!kIsWeb) {
      return PhoneOtpVerifyResult(isSuccess: false, errorMessage: "Not running on Web platform.");
    }

    final completer = Completer<PhoneOtpVerifyResult>();
    final callbackName = "verifyPhoneOtpCb_${DateTime.now().millisecondsSinceEpoch}";

    js.context[callbackName] = (String jsonStr) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        if (data['status'] == 'success') {
          completer.complete(
            PhoneOtpVerifyResult(
              isSuccess: true,
              uid: data['uid'],
              phoneNumber: data['phoneNumber'],
            ),
          );
        } else {
          completer.complete(
            PhoneOtpVerifyResult(
              isSuccess: false,
              errorMessage: data['message'] ?? data['code'] ?? "Incorrect verification code.",
            ),
          );
        }
      } catch (e) {
        completer.complete(PhoneOtpVerifyResult(isSuccess: false, errorMessage: e.toString()));
      } finally {
        js.context.deleteProperty(callbackName);
      }
    };

    try {
      js.context.callMethod('verifyFirebasePhoneSms', [otpCode, callbackName]);
    } catch (e) {
      completer.complete(PhoneOtpVerifyResult(isSuccess: false, errorMessage: e.toString()));
    }

    return completer.future;
  }
}
