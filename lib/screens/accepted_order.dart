import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AcceptedOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AcceptedOrderScreen();
  }
}

class _AcceptedOrderScreen extends State<AcceptedOrder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where(
            'acceptedBy',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final orders = snapshot.data!.docs;
        final activeOrders = orders.where((doc) {
          final status = doc.data()['status'];
          return status == 'accepted';
        }).toList();

        if (activeOrders.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('No active orders found.')),
          );
        }

        final order = activeOrders.first;

        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              ListTile(title: Text(order['address'] as String)),
              Image.network(
                'https://maps.googleapis.com/maps/api/staticmap?center=${order['latitude']},${order['longitude']}&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:Here%7C${order['latitude']},${order['longitude']}&key=AIzaSyD6JQEllj0Y0wCs7KdP5MXhMGNSFAZgC3g',
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.id)
                      .update({'status': 'done'});
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.done),
              ),
            ],
          ),
        );
      },
    );
  }
}
