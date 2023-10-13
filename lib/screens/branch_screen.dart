import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BranchScreen extends StatefulWidget {
  @override
  _BranchScreenState createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _branchNameController = TextEditingController();
  TextEditingController _branchLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Branch Screen"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create a New Branch",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _branchNameController,
              decoration: InputDecoration(labelText: "Branch Name"),
            ),
            TextField(
              controller: _branchLocationController,
              decoration: InputDecoration(labelText: "Branch Location"),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save branch data to Firestore
                saveBranchData();
              },
              child: Text("Save Branch"),
            ),
            SizedBox(height: 24.0),
            Text(
              "Branch List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Display a list of branches
            _buildBranchList(),
          ],
        ),
      ),
    );
  }

  // Function to save branch data
  Future<void> saveBranchData() async {
    String branchName = _branchNameController.text.trim();
    String branchLocation = _branchLocationController.text.trim();

    if (branchName.isNotEmpty && branchLocation.isNotEmpty) {
      try {
        await _firestore.collection('branches').add({
          'branchName': branchName,
          'branchLocation': branchLocation,
        });

        // Clear the text fields
        _branchNameController.clear();
        _branchLocationController.clear();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Branch data saved successfully"),
          ),
        );
      } catch (e) {
        // Handle errors here
        print("Error saving branch data: $e");
      }
    } else {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Branch name and location are required."),
        ),
      );
    }
  }

  // Function to build the list of branches
  Widget _buildBranchList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('branches').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final branches = snapshot.data!.docs;

        List<Widget> branchWidgets = [];

        for (var branch in branches) {
          final branchName = branch['branchName'];
          final branchLocation = branch['branchLocation'];
          final branchId = branch.id;

          branchWidgets.add(
            ListTile(
              title: Text(branchName),
              subtitle: Text(branchLocation),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Edit the branch
                      editBranch(branchId, branchName, branchLocation);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Delete the branch
                      deleteBranch(branchId);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: branchWidgets,
        );
      },
    );
  }

  // Function to edit a branch
  void editBranch(String branchId, String currentName, String currentLocation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _editBranchNameController =
            TextEditingController(text: currentName);
        TextEditingController _editBranchLocationController =
            TextEditingController(text: currentLocation);

        return AlertDialog(
          title: Text("Edit Branch"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editBranchNameController,
                decoration: InputDecoration(labelText: "Branch Name"),
              ),
              TextField(
                controller: _editBranchLocationController,
                decoration: InputDecoration(labelText: "Branch Location"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                saveEditedBranchData(
                  branchId,
                  _editBranchNameController.text.trim(),
                  _editBranchLocationController.text.trim(),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to save edited branch data
  Future<void> saveEditedBranchData(
      String branchId, String editedName, String editedLocation) async {
    try {
      await _firestore.collection('branches').doc(branchId).update({
        'branchName': editedName,
        'branchLocation': editedLocation,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Branch data updated successfully"),
        ),
      );
    } catch (e) {
      print("Error updating branch data: $e");
    }
  }

  // Function to delete a branch
  void deleteBranch(String branchId) async {
    try {
      await _firestore.collection('branches').doc(branchId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Branch deleted successfully"),
        ),
      );
    } catch (e) {
      print("Error deleting branch data: $e");
    }
  }
}
