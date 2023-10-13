// import 'package:firebase_auth_tutorial/services/auth.dart';
// import 'package:flutter/material.dart';

// class SignIn extends StatefulWidget {
//   const SignIn({super.key});

//   @override
//   State<SignIn> createState() => _SignInState();
// }

// class _SignInState extends State<SignIn> {
//   final AuthServices _auth = AuthServices();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("SIGN IN"),
//       ),
//       body: ElevatedButton(
//         child: const Text("Sign in Anonymously"),
//         onPressed: () async {
//           dynamic resulut = await _auth.signInAnonymously();

//           if (resulut == Null) {
//             print("error in signin anonymously");
//           } else {
//             print("signed in anonymously");
//             print(resulut.uid);
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:firebase_auth_tutorial/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_tutorial/screens/authentication/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("SIGN IN"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // User Icon (You can replace the Icon with your user image)
            Icon(
              Icons.person,
              size: 110.0,
              color: Colors.blue, // Customize the icon color
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true, // Hide the password
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              child: const Text("Sign In"),
              onPressed: () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (email.isNotEmpty && password.isNotEmpty) {
                  try {
                    // Check if the email and password match a document in Firestore
                    final query = await _firestore
                        .collection('users')
                        .where('email', isEqualTo: email)
                        .where('password', isEqualTo: password)
                        .get();

                    if (query.docs.isNotEmpty) {
                      // Sign in successful
                      print("Signed in with email and password");

                      // Navigate to the Home screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home(userEmail: email)),
                      );
                    } else {
                      // Email or password is incorrect
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Sign-In Error"),
                            content: Text("Incorrect email or password."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (e) {
                    // Handle any errors that occur
                    print("Error signing in: $e");
                  }
                } else {
                  // Email or password is empty
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Sign-In Error"),
                        content: Text("Email and password are required."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),

            SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                // Navigate to the Register screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
