import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<NotificationMessage> notifications = snapshot.data!.docs
              .map((doc) => NotificationMessage.fromSnapshot(doc))
              .toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final NotificationMessage notification = notifications[index];
              return ListTile(
                title: Text(notification.message),
                subtitle: Text(notification.dateTime),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationMessage {
  final String id;
  final String message;
  final String dateTime;
  final String fundRequestId;

  NotificationMessage({
    required this.id,
    required this.message,
    required this.dateTime,
    required this.fundRequestId,
  });

  factory NotificationMessage.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return NotificationMessage(
      id: snapshot.id,
      message: data['message'] ?? '',
      dateTime: data['dateTime'] ?? '',
      fundRequestId: data['fundRequestId'] ?? '',
    );
  }
}
