import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncoScreen extends StatefulWidget {
  @override
  _IncoScreenState createState() => _IncoScreenState();
}

class _IncoScreenState extends State<IncoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Transfer> incomingRequests = [];

  String? currentUserEmail; // You should set this to the current user's email
  String? loggedInUserBranch;

  @override
  void initState() {
    super.initState();

    getCurrentUserBranch();
    getCurrentUserEmail();
    fetchIncomingRequests();
  }

  void getCurrentUserEmail() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        currentUserEmail = user.email;
      } else {
        // User is not logged in or not available
      }
    } catch (e) {
      print('Error getting current user email: $e');
    }
  }

  // void getCurrentUserEmail() async {
  //   final User? user = _auth.currentUser;
  //   if (user != null) {
  //     loggedInUserEmail = user.email;
  //   }
  // }

  void getCurrentUserBranch() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      // Assuming the branch is stored in a field called 'selectedBranch'
      loggedInUserBranch = userDoc["selectedBranch"] as String?;
    }
  }

  void fetchIncomingRequests() async {
    try {
      final QuerySnapshot requestSnapshot = await _firestore
          .collection('transfers')
          .where('fromBranch', isEqualTo: loggedInUserBranch)
          .get();
      List<Transfer> requests = requestSnapshot.docs
          .map((doc) => Transfer.fromSnapshot(doc))
          .toList();
      setState(() {
        incomingRequests = requests;
      });
    } catch (e) {
      print('Error fetching incoming requests: $e');
    }
  }

  void approveRequest(String requestId) async {
    try {
      await _firestore.collection('transfers').doc(requestId).update({
        'isApproved': true,
      });

      // Save approved request details to the 'inco' collection
      await _firestore.collection('inco').add({
        'approvedBy': currentUserEmail,
        'approvalDateTime': DateTime.now(),
        'requestId': requestId,
      });

      // Refresh the incoming requests list
      fetchIncomingRequests();
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  void rejectRequest(String requestId) async {
    try {
      await _firestore.collection('transfers').doc(requestId).update({
        'isApproved': false,
      });

      // Refresh the incoming requests list
      fetchIncomingRequests();
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Incoming Fund Requests"),
      ),
      body: ListView.builder(
        itemCount: incomingRequests.length,
        itemBuilder: (context, index) {
          final Transfer request = incomingRequests[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              title: Text("Amount: ${request.amount}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description: ${request.description}"),
                  Text("Req Branch: ${request.reqBranch}"),
                  Text("From Branch: ${request.fromBranch}"),
                  Text("Date/Time: ${request.dateTime}"),
                  Text("User: ${request.user}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: request.isApproved == false
                        ? () => approveRequest(request.id)
                        : null,
                    child: Text("Approve"),
                  ),
                  ElevatedButton(
                    onPressed: request.isApproved == false
                        ? () => rejectRequest(request.id)
                        : null,
                    child: Text("Reject"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Transfer {
  final String id;
  final String amount;
  final String description;
  final String reqBranch;
  final String fromBranch;
  final String dateTime;
  final String user;
  final bool? isApproved;

  Transfer({
    required this.id,
    required this.amount,
    required this.description,
    required this.reqBranch,
    required this.fromBranch,
    required this.dateTime,
    required this.user,
    this.isApproved,
  });

  factory Transfer.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Transfer(
      id: snapshot.id,
      amount: data['amount'] ?? '',
      description: data['description'] ?? '',
      reqBranch: data['reqBranch'] ?? '',
      fromBranch: data['fromBranch'] ?? '',
      dateTime: data['dateTime'] ?? '',
      user: data['user'] ?? '',
      isApproved: data['isApproved'] ?? null,
    );
  }
}
