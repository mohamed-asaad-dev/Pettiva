import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettiva_v2/screens/accepted_order.dart';

class FleetScreen extends StatefulWidget {
  @override
  State<FleetScreen> createState() {
    return _FleetScreenState();
  }
}

class _FleetScreenState extends State<FleetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'posted')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          final availabeOrders = orders.where((doc) {
            final orderData = doc.data();
            final dismissedBy = List<String>.from(
              orderData['rejectedBy'] ?? [],
            );
            return !dismissedBy.contains(
              FirebaseAuth.instance.currentUser!.uid,
            );
          }).toList();

          return ListView.builder(
            itemCount: availabeOrders.length,
            itemBuilder: (context, index) {
              final data = availabeOrders[index].data();

              return InkWell(
                onTap: () {},
                child: Dismissible(
                  key: ValueKey(data),
                  onDismissed: (direction) {
                    FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orders[index].id)
                        .update({
                          'rejectedBy': FieldValue.arrayUnion([
                            FirebaseAuth.instance.currentUser!.uid,
                          ]),
                        });
                  },
                  background: Container(color: Colors.red),
                  child: ListBody(
                    children: [
                      Text(
                        data['address'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Text(
                            data['time'] as String,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orders[index].id)
                                  .update({
                                    'status': 'accepted',
                                    'acceptedBy':
                                        FirebaseAuth.instance.currentUser!.uid,
                                  });
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AcceptedOrder();
                                  },
                                ),
                              );
                            },
                            icon: Icon(Icons.check),
                          ),
                          IconButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orders[index].id)
                                  .update({
                                    'rejectedBy': FieldValue.arrayUnion([
                                      FirebaseAuth.instance.currentUser!.uid,
                                    ]),
                                  });
                            },
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
