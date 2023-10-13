// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth_tutorial/models/UserModel.dart';

// class AuthServices {
// //ano

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // create a user from uid
//   UserModel? _userWithFirebaseUserUid(User? user) {
//     return user != null ? UserModel(uid: user.uid) : null;
//   }

// // create the streamn
//   Stream<UserModel?> get user {
//     return _auth.authStateChanges().map(_userWithFirebaseUserUid);
//   }

//   Future signInAnonymously() async {
//     try {
//       UserCredential result = await _auth.signInAnonymously();
//       User? user = result.user;
//       return _userWithFirebaseUserUid(user);
//     } catch (err) {
//       print(err.toString());
//       return null;
//     }
//   }

// //reg emailp
// //signin emailpw

// //sign in using gmail
// //signout

//   Future signOut() async {
//     try {
//       return await _auth.signOut();
//     } catch (err) {
//       print(err.toString());
//       return null;
//     }
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_tutorial/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userWithFirebaseUserUid(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userWithFirebaseUserUid);
  }

  Future<UserModel?> signInWithEmailAndPassword(
      String username, String password) async {
    try {
      // Check Firestore for the provided username and password
      final userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password) // Ensure secure hashing
          .limit(1) // Limit to one result
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data() as Map<String, dynamic>;
        final userId = userData['uid'];

        // Sign in with Firebase Authentication using the user's UID
        await _auth.signInWithCustomToken(userId);
        final currentUser = _auth.currentUser;
        return _userWithFirebaseUserUid(currentUser);
      } else {
        // User not found in Firestore
        return null;
      }
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (err) {
      print(err.toString());
      return null;
    }
  }
}
