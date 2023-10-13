import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BbalScreen extends StatefulWidget {
  @override
  _BbalScreenState createState() => _BbalScreenState();
}

class _BbalScreenState extends State<BbalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Branch-Wise Balances"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('directtrans').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final documents = snapshot.data?.docs ?? [];

          final branchBalances = Map<String, double>();

          for (var doc in documents) {
            final branch = doc['branch'] as String;
            final amount = doc['amount'] as double;

            // Calculate total amount for each branch
            if (branchBalances.containsKey(branch)) {
              branchBalances[branch] = (branchBalances[branch] ?? 0.0) + amount;
            } else {
              branchBalances[branch] = amount;
            }
          }

          return ListView.builder(
            itemCount: branchBalances.length,
            itemBuilder: (context, index) {
              final branch = branchBalances.keys.elementAt(index);
              final totalBalance = branchBalances[branch];

              return ListTile(
                title: Text("Branch: $branch"),
                subtitle: Text(
                    "Total Balance: ${totalBalance?.toStringAsFixed(2) ?? 'N/A'}"),
              );
            },
          );
        },
      ),
    );
  }
}
