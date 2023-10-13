import 'package:firebase_auth_tutorial/screens/wrapper.dart';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //     options: FirebaseOptions(
// //       persistenceEnabled: true, // Enable offline persistence
// //     ),
// //   );
// //   runApp(MyApp());
// // }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamProvider<UserModel?>.value(
//       initialData: UserModel(uid: ""),
//       value: AuthServices().user,
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Wrapper(),
//       ),
//     );
//   }
// }

import 'package:firebase_auth_tutorial/screens/home/home.dart'; // Import the Home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Define the '/home' route here
      routes: {
        '/home': (context) => Home(userEmail: "userEmail"),
      },
      home: Wrapper(),
    );
  }
}
