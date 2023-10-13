import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UProfileScreen extends StatefulWidget {
  @override
  _UProfileScreenState createState() => _UProfileScreenState();
}

class _UProfileScreenState extends State<UProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  Future<void> _loadUserProfileData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      // Load user data from Firestore
      final userData = await _firestore.collection('users').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          _userEmail = user.email;
          _firstNameController.text = userData.data()?['firstName'] ?? "";
          _lastNameController.text = userData.data()?['lastName'] ?? "";
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      // Update user profile data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              readOnly: true,
              initialValue: _userEmail,
            ),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
