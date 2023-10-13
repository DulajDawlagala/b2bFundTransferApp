import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FundRequestScreen extends StatefulWidget {
  @override
  _FundRequestScreenState createState() => _FundRequestScreenState();
}

class _FundRequestScreenState extends State<FundRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedBranch;
  bool _isApproved = false;

  List<String> branches = []; // Replace with your actual branches
  String? loggedInUserEmail;
  String? loggedInUserBranch;

  @override
  void initState() {
    super.initState();
    // Fetch branches data from Firestore
    fetchBranches();
    // Get the logged-in user's email
    getCurrentUserEmail();
    getCurrentUserBranch();
  }

  void getCurrentUserBranch() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      // Assuming the branch is stored in a field called 'selectedBranch'
      loggedInUserBranch = userDoc['selectedBranch'] as String?;
    }
  }

  void getCurrentUserEmail() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      loggedInUserEmail = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fund Request"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create a New Fund Request",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            DropdownButton<String>(
              value: _selectedBranch,
              hint: Text("From Branch"),
              items: branches.map((String branchName) {
                return DropdownMenuItem<String>(
                  value: branchName,
                  child: Text(branchName),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedBranch = value;
                });
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: _isApproved,
                  onChanged: (bool? value) {
                    setState(() {
                      _isApproved = value ?? false;
                    });
                  },
                ),
                Text("Is Approved"),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Create a new fund request and save it to Firestore
                createFundRequest();
              },
              child: Text("Create Fund Request"),
            ),
            SizedBox(height: 16.0),
            Text(
              "Fund Request List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            buildFundRequestsList(),
          ],
        ),
      ),
    );
  }

  void fetchBranches() async {
    QuerySnapshot branchSnapshot =
        await _firestore.collection('branches').get();
    List<String> branchNames =
        branchSnapshot.docs.map((doc) => doc['branchName'] as String).toList();
    setState(() {
      branches = branchNames;
    });
  }

  Future<void> createFundRequest() async {
    String amount = _amountController.text.trim();
    String description = _descriptionController.text.trim();

    if (amount.isNotEmpty &&
        description.isNotEmpty &&
        _selectedBranch != null &&
        loggedInUserBranch != null &&
        loggedInUserEmail != null) {
      try {
        final DateTime now = DateTime.now();
        final String formattedDateTime =
            "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";

        // Save fund request data to Firestore
        DocumentReference fundRequestDoc =
            await _firestore.collection('transfers').add({
          'amount': amount,
          'description': description,
          'reqBranch': loggedInUserBranch,
          'fromBranch': _selectedBranch,
          'dateTime': formattedDateTime,
          'user': loggedInUserEmail,
          'isApproved': _isApproved,
        });

        // Create and save a notification
        await _firestore.collection('notifications').add({
          'message': 'New fund request created by $loggedInUserEmail',
          'dateTime': formattedDateTime,
          'relatedFundRequest': fundRequestDoc.id,
        });

        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedBranch = null;
          _isApproved = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fund request created successfully"),
          ),
        );
      } catch (e) {
        print("Error creating fund request: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Amount, description, and branch are required."),
        ),
      );
    }
  }

  Widget buildFundRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transfers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<Widget> fundRequestWidgets = [];

        for (DocumentSnapshot doc in snapshot.data!.docs) {
          final String amount = doc['amount'].toString();
          final String description = doc['description'].toString();
          final String reqBranch = doc['reqBranch'].toString();
          final String fromBranch = doc['fromBranch'].toString();
          final String dateTime = doc['dateTime'].toString();
          final String user = doc['user'].toString();
          final bool isApproved = doc['isApproved'];

          final fundRequestWidget = FundRequestWidget(
            amount: amount,
            description: description,
            reqBranch: reqBranch,
            fromBranch: fromBranch,
            dateTime: dateTime,
            user: user,
            isApproved: isApproved,
            onCancel: () {
              deleteFundRequest(doc.id);
            },
          );

          fundRequestWidgets.add(fundRequestWidget);
        }

        return Column(
          children: fundRequestWidgets,
        );
      },
    );
  }

  Future<void> deleteFundRequest(String requestId) async {
    try {
      await _firestore.collection('transfers').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fund request cancelled"),
        ),
      );
    } catch (e) {
      print("Error cancelling fund request: $e");
    }
  }
}

class FundRequestWidget extends StatelessWidget {
  final String amount;
  final String description;
  final String reqBranch;
  final String fromBranch;
  final String dateTime;
  final String user;
  final bool isApproved;
  final VoidCallback onCancel;

  FundRequestWidget({
    required this.amount,
    required this.description,
    required this.reqBranch,
    required this.fromBranch,
    required this.dateTime,
    required this.user,
    required this.isApproved,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text("Amount: $amount"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description: $description"),
            Text("Req Branch: $reqBranch"),
            Text("From Branch: $fromBranch"),
            Text("Date Time: $dateTime"),
            Text("User: $user"),
            Text("Is Approved: ${isApproved ? 'Yes' : 'No'}"),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onCancel,
          child: Text("Cancel"),
        ),
      ),
    );
  }
}
