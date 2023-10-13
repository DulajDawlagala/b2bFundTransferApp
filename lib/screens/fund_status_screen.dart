import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FundStatusScreen extends StatefulWidget {
  @override
  _FundStatusScreenState createState() => _FundStatusScreenState();
}

class _FundStatusScreenState extends State<FundStatusScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fund Status"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('transfers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Widget> transactionWidgets = [];
          for (DocumentSnapshot doc in snapshot.data!.docs) {
            final bool isApproved = doc['isApproved'] ?? false;
            final Color tileColor = isApproved ? Colors.green : Colors.red;

            final ListTile transactionTile = ListTile(
              title: Text("Amount: ${doc['amount']}"),
              subtitle: Text("Description: ${doc['description']}"),
              trailing: Icon(Icons.check, color: tileColor),
            );

            transactionWidgets.add(transactionTile);
          }

          return ListView(
            children: transactionWidgets,
          );
        },
      ),
    );
  }
}
