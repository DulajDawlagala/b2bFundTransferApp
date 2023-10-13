// import 'package:flutter/material.dart';
// import 'package:firebase_auth_tutorial/models/UserModel.dart';
// import 'package:firebase_auth_tutorial/screens/authentication/authenticate.dart';
// import 'package:firebase_auth_tutorial/screens/home/home.dart';
// import 'package:provider/provider.dart';

// class Wrapper extends StatelessWidget {
//   const Wrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     //the user data that the provider proides this can be a user data or can be null.
//     final user = Provider.of<UserModel?>(context);

//     if (user == null) {
//       return Authenticate();
//     } else {
//       return Home();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth_tutorial/models/UserModel.dart';
import 'package:firebase_auth_tutorial/screens/authentication/authenticate.dart';
import 'package:firebase_auth_tutorial/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check the authentication status of the user
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      // User is not authenticated, show the authentication screen
      return Authenticate();
    } else {
      // User is authenticated, show the home screen
      return Home(userEmail: "userEmail");
    }
  }
}
