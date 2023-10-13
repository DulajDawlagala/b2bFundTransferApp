import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankScreen extends StatefulWidget {
  @override
  _BankScreenState createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankLocationController = TextEditingController();

  String? selectedBankId;
  List<Bank> banks = [];
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchBanks();
  }

  void fetchBanks() async {
    try {
      final QuerySnapshot bankSnapshot =
          await _firestore.collection('banks').get();

      setState(() {
        banks = bankSnapshot.docs.map((doc) => Bank.fromSnapshot(doc)).toList();
      });
    } catch (e) {
      print('Error fetching banks: $e');
    }
  }

  void saveBank() async {
    final String bankName = _bankNameController.text.trim();
    final String bankLocation = _bankLocationController.text.trim();

    if (bankName.isNotEmpty && bankLocation.isNotEmpty) {
      try {
        if (isEditing) {
          await _firestore.collection('banks').doc(selectedBankId).update({
            'bankName': bankName,
            'bankLocation': bankLocation,
          });
        } else {
          await _firestore.collection('banks').add({
            'bankName': bankName,
            'bankLocation': bankLocation,
          });
        }

        _bankNameController.clear();
        _bankLocationController.clear();

        setState(() {
          isEditing = false;
          selectedBankId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bank data saved successfully'),
          ),
        );

        fetchBanks(); // Refresh the bank list
      } catch (e) {
        print('Error saving bank data: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bank name and location are required.'),
        ),
      );
    }
  }

  void editBank(Bank bank) {
    _bankNameController.text = bank.bankName;
    _bankLocationController.text = bank.bankLocation;
    setState(() {
      isEditing = true;
      selectedBankId = bank.id;
    });
  }

  void deleteBank(String id) async {
    try {
      await _firestore.collection('banks').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bank deleted successfully'),
        ),
      );
      fetchBanks(); // Refresh the bank list
    } catch (e) {
      print('Error deleting bank: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Screen"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Bank' : 'Create a New Bank',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _bankNameController,
                  decoration: InputDecoration(labelText: "Bank Name"),
                ),
                TextField(
                  controller: _bankLocationController,
                  decoration: InputDecoration(labelText: "Bank Location"),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: saveBank,
                  child: Text(isEditing ? 'Update Bank' : 'Save Bank'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return ListTile(
                  title: Text(bank.bankName),
                  subtitle: Text(bank.bankLocation),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editBank(bank),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteBank(bank.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Bank {
  final String id;
  final String bankName;
  final String bankLocation;

  Bank({
    required this.id,
    required this.bankName,
    required this.bankLocation,
  });

  factory Bank.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bank(
      id: doc.id,
      bankName: data['bankName'] ?? '',
      bankLocation: data['bankLocation'] ?? '',
    );
  }
}
