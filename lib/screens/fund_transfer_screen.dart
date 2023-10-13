import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FundTransferScreen extends StatefulWidget {
  @override
  _FundTransferScreenState createState() => _FundTransferScreenState();
}

class _FundTransferScreenState extends State<FundTransferScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String user = '';
  double amount = 0.0;
  String description = '';
  DateTime selectedDate = DateTime.now();
  String selectedFromBank = '';
  String selectedToBank = '';
  String selectedFromBranch = '';
  String selectedToBranch = '';

  List<String> bankNames = [];
  List<String> branchNames = [];

  List<DocumentSnapshot> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchBankNames();
    fetchBranchNames();
    fetchTransactions();
  }

  Future<void> fetchBankNames() async {
    QuerySnapshot banksSnapshot = await _firestore.collection('banks').get();

    if (banksSnapshot.docs.isNotEmpty) {
      setState(() {
        final uniqueBankNames = <String>{};
        for (final doc in banksSnapshot.docs) {
          final bankName = doc['bankName'] as String;
          uniqueBankNames.add(bankName);
        }

        bankNames = uniqueBankNames.toList();
        selectedFromBank = bankNames.isNotEmpty ? bankNames[0] : '';
        selectedToBank = bankNames.isNotEmpty ? bankNames[0] : '';
      });
    }
  }

  Future<void> fetchBranchNames() async {
    QuerySnapshot branchesSnapshot =
        await _firestore.collection('branches').get();

    if (branchesSnapshot.docs.isNotEmpty) {
      setState(() {
        final uniqueBranchNames = <String>{};
        for (final doc in branchesSnapshot.docs) {
          final branchName = doc['branchName'] as String;
          uniqueBranchNames.add(branchName);
        }

        branchNames = uniqueBranchNames.toList();
        selectedFromBranch = branchNames.isNotEmpty ? branchNames[0] : '';
        selectedToBranch = branchNames.isNotEmpty ? branchNames[0] : '';
      });
    }
  }

  Future<void> fetchTransactions() async {
    try {
      QuerySnapshot transactionsSnapshot =
          await _firestore.collection('directtrans').get();

      if (transactionsSnapshot.docs.isNotEmpty) {
        setState(() {
          transactions = transactionsSnapshot.docs;
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fund Transfer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Amount:"),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 1.0),
            Text("Description:"),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            SizedBox(height: 1.0),
            Text("Date:"),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.date_range,
                    size: 16,
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 1.0),
            Text("From Bank:"),
            DropdownButton<String>(
              value: selectedFromBank,
              onChanged: (value) {
                setState(() {
                  selectedFromBank = value!;
                });
              },
              items: bankNames.map((bankName) {
                return DropdownMenuItem<String>(
                  value: bankName,
                  child: Text(bankName),
                );
              }).toList(),
            ),
            SizedBox(height: 1.0),
            Text("To Bank:"),
            DropdownButton<String>(
              value: selectedToBank,
              onChanged: (value) {
                setState(() {
                  selectedToBank = value!;
                });
              },
              items: bankNames.map((bankName) {
                return DropdownMenuItem<String>(
                  value: bankName,
                  child: Text(bankName),
                );
              }).toList(),
            ),
            SizedBox(height: 1.0),
            Text("From Branch:"),
            DropdownButton<String>(
              value: selectedFromBranch,
              onChanged: (value) {
                setState(() {
                  selectedFromBranch = value!;
                });
              },
              items: branchNames.map((branchName) {
                return DropdownMenuItem<String>(
                  value: branchName,
                  child: Text(branchName),
                );
              }).toList(),
            ),
            SizedBox(height: 1.0),
            Text("To Branch:"),
            DropdownButton<String>(
              value: selectedToBranch,
              onChanged: (value) {
                setState(() {
                  selectedToBranch = value!;
                });
              },
              items: branchNames.map((branchName) {
                return DropdownMenuItem<String>(
                  value: branchName,
                  child: Text(branchName),
                );
              }).toList(),
            ),
            SizedBox(height: 1.0),
            ElevatedButton(
              onPressed: () {
                _submitTransaction();
              },
              child: Text("Submit Fund Transfer"),
            ),
            SizedBox(height: 10),
            Text(
              "Saved Transactions:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            transactions.isEmpty
                ? Text("No transactions to display")
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot transaction = transactions[index];
                        return Card(
                          child: ListTile(
                            title: Text("Amount: ${transaction['amount']}"),
                            subtitle: Text(
                                "Description: ${transaction['description']}"),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteTransaction(transaction.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTransaction() async {
    try {
      CollectionReference directTrans = _firestore.collection('directtrans');

      // Save the "From" side (debit)
      await directTrans.add({
        'user': user,
        'amount': -amount, // Debit amount (negative value)
        'description': description,
        'date': selectedDate.toLocal().toString(),
        'bank': selectedFromBank,
        'branch': selectedFromBranch,
      });

      // Save the "To" side (credit)
      await directTrans.add({
        'user': user,
        'amount': amount, // Credit amount (positive value)
        'description': description,
        'date': selectedDate.toLocal().toString(),
        'bank': selectedToBank,
        'branch': selectedToBranch,
      });

      // Data added successfully
      print('Transaction data added to Firestore.');

      // Reset form fields and date
      setState(() {
        user = '';
        amount = 0.0;
        description = '';
        selectedDate = DateTime.now();
        selectedFromBank = bankNames.isNotEmpty ? bankNames[0] : '';
        selectedToBank = bankNames.isNotEmpty ? bankNames[0] : '';
        selectedFromBranch = branchNames.isNotEmpty ? branchNames[0] : '';
        selectedToBranch = branchNames.isNotEmpty ? branchNames[0] : '';
      });

      // Fetch updated transactions
      fetchTransactions();
    } catch (e) {
      // Error handling
      print('Error adding transaction data to Firestore: $e');
    }
  }

  Future<void> _deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('directtrans').doc(transactionId).delete();

      // Fetch updated transactions after deletion
      fetchTransactions();
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }
}

class Transaction {
  final String id;
  final String user;
  final double amount;
  final String description;
  final DateTime date;
  final String fromBank;
  final String fromBranch;

  Transaction({
    required this.id,
    required this.user,
    required this.amount,
    required this.description,
    required this.date,
    required this.fromBank,
    required this.fromBranch,
  });
}
