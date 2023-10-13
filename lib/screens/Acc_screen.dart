import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _accCodeController = TextEditingController();
  final TextEditingController _accNameController = TextEditingController();
  String? _selectedBranch;
  String? _selectedBank;
  bool _isBankAccount = false;
  bool _isCashAccount = false;

  List<String> branches = []; // Replace with your actual branches
  List<String> banks = []; // Replace with your actual banks
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    // Fetch branches and banks data from Firestore
    fetchBranches();
    fetchBanks();
    // Fetch existing accounts data from Firestore
    fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Screen"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create a New Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _accCodeController,
              decoration: InputDecoration(labelText: "Account Code"),
            ),
            TextField(
              controller: _accNameController,
              decoration: InputDecoration(labelText: "Account Name"),
            ),
            DropdownButton<String>(
              value: _selectedBranch,
              hint: Text("Select Branch"),
              items: branches.map((String branch) {
                return DropdownMenuItem<String>(
                  value: branch,
                  child: Text(branch),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedBranch = value;
                });
              },
            ),
            DropdownButton<String>(
              value: _selectedBank,
              hint: Text("Select Bank"),
              items: banks.map((String bank) {
                return DropdownMenuItem<String>(
                  value: bank,
                  child: Text(bank),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedBank = value;
                });
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: _isBankAccount,
                  onChanged: (bool? value) {
                    setState(() {
                      _isBankAccount = value ?? false;
                    });
                  },
                ),
                Text("Is Bank Account"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isCashAccount,
                  onChanged: (bool? value) {
                    setState(() {
                      _isCashAccount = value ?? false;
                    });
                  },
                ),
                Text("Is Cash Account"),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save account data to Firestore
                saveAccountData();
              },
              child: Text("Save Account"),
            ),
            SizedBox(height: 16.0),
            Text(
              "Accounts List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            buildAccountsList(),
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

  void fetchBanks() async {
    QuerySnapshot bankSnapshot = await _firestore.collection('banks').get();
    List<String> bankNames =
        bankSnapshot.docs.map((doc) => doc['bankName'] as String).toList();
    setState(() {
      banks = bankNames;
    });
  }

  void fetchAccounts() async {
    QuerySnapshot accountSnapshot =
        await _firestore.collection('accounts').get();
    List<Account> accountList =
        accountSnapshot.docs.map((doc) => Account.fromSnapshot(doc)).toList();
    setState(() {
      accounts = accountList;
    });
  }

  Future<void> saveAccountData() async {
    String accCode = _accCodeController.text.trim();
    String accName = _accNameController.text.trim();

    if (accCode.isNotEmpty && accName.isNotEmpty) {
      try {
        // Save account data to Firestore
        await _firestore.collection('accounts').add({
          'accCode': accCode,
          'accName': accName,
          'branch': _selectedBranch,
          'bank': _selectedBank,
          'isBankAccount': _isBankAccount,
          'isCashAccount': _isCashAccount,
        });

        // Clear the text fields and reset selections
        _accCodeController.clear();
        _accNameController.clear();
        setState(() {
          _selectedBranch = null;
          _selectedBank = null;
          _isBankAccount = false;
          _isCashAccount = false;
        });

        // Show a success message or navigate to a different screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account data saved successfully"),
          ),
        );
      } catch (e) {
        // Handle errors here
        print("Error saving account data: $e");
      }
    } else {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account code and name are required."),
        ),
      );
    }
  }

  Widget buildAccountsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final Account account = accounts[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text("Account Name: ${account.accName}"),
            subtitle: Text("Account Code: ${account.accCode}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Implement edit functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Implement delete functionality
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Account {
  final String id;
  final String accCode;
  final String accName;
  final String? branch;
  final String? bank;
  final bool isBankAccount;
  final bool isCashAccount;

  Account({
    required this.id,
    required this.accCode,
    required this.accName,
    required this.branch,
    required this.bank,
    required this.isBankAccount,
    required this.isCashAccount,
  });

  // Factory constructor to parse data from Firestore snapshot
  factory Account.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Account(
      id: snapshot.id,
      accCode: data['accCode'] ?? '',
      accName: data['accName'] ?? '',
      branch: data['branch'] ?? '',
      bank: data['bank'] ?? '',
      isBankAccount: data['isBankAccount'] ?? false,
      isCashAccount: data['isCashAccount'] ?? false,
    );
  }
}
