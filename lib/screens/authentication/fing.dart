import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintRegistrationScreen extends StatelessWidget {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<void> _registerFingerprint() async {
    try {
      bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      if (canCheckBiometrics) {
        List<BiometricType> availableBiometrics =
            await _localAuthentication.getAvailableBiometrics();
        if (availableBiometrics.contains(BiometricType.fingerprint)) {
          bool didAuthenticate = await _localAuthentication.authenticate(
            localizedReason: 'Scan your fingerprint to register',
            // useErrorDialogs: true,
            // stickyAuth:true, // Prevents the user from quitting the app during authentication
          );
          if (didAuthenticate) {
            // Fingerprint registration successful, you can save user data
            // and proceed to the next steps.
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fingerprint Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your input fields here (e.g., name, email)
            ElevatedButton(
              onPressed: _registerFingerprint,
              child: Text('Register Fingerprint'),
            ),
          ],
        ),
      ),
    );
  }
}
