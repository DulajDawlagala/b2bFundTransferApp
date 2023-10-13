import 'package:flutter/material.dart';
import 'package:firebase_auth_tutorial/services/auth.dart';
import 'package:firebase_auth_tutorial/screens/fund_request_screen.dart';
import 'package:firebase_auth_tutorial/screens/fund_transfer_screen.dart';
import 'package:firebase_auth_tutorial/screens/bank_screen.dart';
import 'package:firebase_auth_tutorial/screens/fund_status_screen.dart';
import 'package:firebase_auth_tutorial/screens/branch_screen.dart';
import 'package:firebase_auth_tutorial/screens/bbal_screen.dart';
import 'package:firebase_auth_tutorial/screens/Acc_screen.dart';
import 'package:firebase_auth_tutorial/screens/inco_screen.dart';
import 'package:firebase_auth_tutorial/screens/notifications_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  final String userEmail;

  Home({required this.userEmail});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthServices _auth = AuthServices();

  Future<double> getTotalBalance() async {
    double totalBalance = 0.0;
    try {
      QuerySnapshot transactionsSnapshot =
          await FirebaseFirestore.instance.collection('directtrans').get();

      if (transactionsSnapshot.docs.isNotEmpty) {
        for (var doc in transactionsSnapshot.docs) {
          double amount = doc['amount'] ?? 0.0;
          totalBalance += amount;
        }
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }

    return totalBalance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HOME"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
            },
            child: Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // WELCOME Tile
            _buildTileWithText(
              "WELCOME !",
              " ${widget.userEmail}",
              Colors.blue,
            ),
            // BRANCH Tile
            _buildTileWithText(
              "BRANCH",
              // " : ${widget.userEmail}",
              " Kandy ",
              Colors.blue,
            ),
            // Grid of icons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _buildTileWithIcon(
                    "Fund Request",
                    Colors.blue,
                    Icons.request_quote,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FundRequestScreen(),
                        ),
                      );
                    },
                  ),
                  _buildTileWithIcon(
                    "Direct Fund Transfer",
                    Colors.blue,
                    Icons.send,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FundTransferScreen(),
                        ),
                      );
                    },
                  ),
                  _buildTileWithIcon(
                      "Transfer Status", Colors.blue, Icons.dataset, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FundStatusScreen(),
                      ),
                    );
                  }),
                  _buildTileWithIcon("Incoming Requests", Colors.blue,
                      Icons.insert_comment_outlined, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncoScreen(),
                      ),
                    );
                  }),
                  _buildTileWithIcon(
                      "Notifications", Colors.blue, Icons.notifications, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(),
                      ),
                    );
                  }),
                  _buildTileWithIcon(
                      "Branch Balances", Colors.blue, Icons.balance, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BbalScreen(),
                      ),
                    );
                  }),
                  _buildTileWithIcon("Bank Setup", Colors.blue,
                      Icons.account_balance_wallet_sharp, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BankScreen(),
                      ),
                    );
                  }),
                  _buildTileWithIcon("Accounts Setup", Colors.blue,
                      Icons.account_balance_rounded, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountScreen(),
                      ),
                    );
                  }),
                  _buildTileWithIcon(
                      "Branch Setup", Colors.blue, Icons.house_rounded, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BranchScreen(),
                      ),
                    );
                  }),
                  // Add more tiles for other options here
                ],
              ),
            ),
            // Display total balance in a tile
            FutureBuilder<double>(
              future: getTotalBalance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildTileWithText(
                    "BALANCE",
                    "Loading...",
                    Colors.blue,
                  );
                } else if (snapshot.hasError) {
                  return _buildTileWithText(
                    "BALANCE",
                    "Error: ${snapshot.error}",
                    Colors.blue,
                  );
                } else {
                  double totalBalance =
                      snapshot.data ?? 0.0; // Handle null case
                  return _buildTileWithText(
                    "BALANCE",
                    totalBalance.toStringAsFixed(2),
                    Colors.blue,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build tiles with text
  Widget _buildTileWithText(String label, String text, Color color) {
    return Card(
      color: color,
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // Helper function to build tiles with icons
  Widget _buildTileWithIcon(
      String label, Color color, IconData iconData, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 30.0,
              color: Colors.white,
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
