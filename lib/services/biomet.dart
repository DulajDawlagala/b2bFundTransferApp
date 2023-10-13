import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthenticationScreen extends StatelessWidget {
  final LocalAuthentication localAuth = LocalAuthentication();

  Future<void> _authenticateWithBiometrics(BuildContext context) async {
    try {
      final isAvailable = await localAuth.canCheckBiometrics;
      if (isAvailable) {
        final isAuthenticated = await localAuth.authenticate(
          localizedReason: 'Authenticate to access your data.',
          //   stickyAuth: true, // To keep the authentication popup on the screen.
          //biometricOnly:
          //  true, // Use this to require biometrics (no PIN fallback).
        );
        if (isAuthenticated) {
          // Biometric authentication successful, grant access.
          // You can navigate to a protected screen or perform other actions here.
        } else {
          // Biometric authentication failed or was canceled.
        }
      } else {
        // Biometric authentication is not available on this device.
      }
    } catch (e) {
      // Handle any errors that occur during authentication.
      print('Error authenticating with biometrics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Authentication'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _authenticateWithBiometrics(context),
          child: Text('Authenticate with Biometrics'),
        ),
      ),
    );
  }
}
