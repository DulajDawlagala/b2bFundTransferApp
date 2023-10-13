import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController branchCodeController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? errorMessage;
  List<String> branches = [];
  String? selectedBranch;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  void fetchBranches() async {
    try {
      final QuerySnapshot branchSnapshot =
          await _firestore.collection('branches').get();

      setState(() {
        branches = branchSnapshot.docs
            .map((doc) => doc['branchName'] as String)
            .toList();
      });
    } catch (e) {
      print('Error fetching branches: $e');
    }
  }

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // ... Rest of the code remains the same

  Widget _displayImage() {
    if (_imageFile == null) {
      return Container(); // Return an empty container if no image is selected
    }
    return Image.file(_imageFile!);
  }

  void _registerUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String firstName = firstNameController.text;
    final String lastName = lastNameController.text;
    final String branchCode = branchCodeController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Create a new user with email and password
        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        // Get the generated user ID
        final String userId = userCredential.user!.uid;

        // Add user data to Firestore
        await _firestore.collection('users').doc(userId).set({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'branchCode': branchCode,
          'selectedBranch': selectedBranch, // Save selected branch
          'profilePhotoUrl': '', // Initialize with an empty URL
        });

        // Upload the profile photo to storage (you need to implement this)
        if (_imageFile != null) {
          // Implement image upload logic here and get the URL
          final String photoUrl =
              await uploadImageToStorage(_imageFile!, userId);

          // Update the user's profile with the photo URL
          await _firestore.collection('users').doc(userId).update({
            'profilePhotoUrl': photoUrl,
          });
        }

        // Registration successful, clear text inputs
        emailController.clear();
        passwordController.clear();
        firstNameController.clear();
        lastNameController.clear();
        branchCodeController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!'),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          errorMessage = null;
          _imageFile = null; // Clear the selected image
        });
      } catch (e) {
        // Handle registration errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Email or password is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both email and password.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String> uploadImageToStorage(File imageFile, String userId) async {
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(userId)
          .child(
              'profile.jpg'); // Replace 'profile.jpg' with your desired image name

      final UploadTask uploadTask = storageRef.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return an empty string on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: SingleChildScrollView(
        // Wrap the content with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Email:"),
              TextFormField(
                controller: emailController,
              ),
              SizedBox(height: 8.0), // Increase the spacing between elements
              Text("Password:"),
              TextFormField(
                controller: passwordController,
                obscureText: true,
              ),
              SizedBox(height: 8.0),
              Text("First Name:"),
              TextFormField(
                controller: firstNameController,
              ),
              SizedBox(height: 8.0),
              Text("Last Name:"),
              TextFormField(
                controller: lastNameController,
              ),
              SizedBox(height: 8.0),
              Text("Branch Code:"),
              DropdownButton<String>(
                value: selectedBranch,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBranch = newValue;
                  });
                },
                items: branches.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 8.0),
              Text("Profile Photo:"),
              ElevatedButton(
                onPressed: _getImage,
                child: Text("Take Photo"),
              ),
              _displayImage(),
              SizedBox(height: 8.0), // Increase the spacing between elements
              ElevatedButton(
                onPressed: _registerUser,
                child: Text("Register"),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    branchCodeController.dispose();
    super.dispose();
  }
}
