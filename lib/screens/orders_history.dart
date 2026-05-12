import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersHistoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrdersHistoryScreenState();
  }
}

class OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: Text(
          'Completed Requests',
          style: TextStyle(color: Color.fromRGBO(251, 176, 59, 1)),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'done')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('No History');
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 120,
                  child: Card(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    elevation: 20,
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: Icon(
                          Icons.done,
                          color: Color.fromRGBO(251, 176, 59, 1),
                        ),
                      ),
                      title: Text(
                        'Thanks for picking pettiva',
                        style: TextStyle(
                          color: Color.fromRGBO(251, 176, 59, 1),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docs[index]['address'] +
                                ', Building Number: ' +
                                docs[index]['buildingNumber'] +
                                ', Floor Number: ' +
                                docs[index]['floorNumber'] +
                                '.',
                            style: TextStyle(color: Colors.white),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,

                                color: Color.fromRGBO(251, 176, 59, 1),
                              ),
                              SizedBox(width: 3),
                              Text(
                                DateFormat('MMM d, y').format(
                                  (docs[index]['date'] as Timestamp).toDate(),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.alarm,

                                color: Color.fromRGBO(251, 176, 59, 1),
                              ),
                              SizedBox(width: 3),
                              Text(
                                docs[index]['time'] as String,

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              Spacer(),

                              docs[index]['serviceType'] == 'standard'
                                  ? Icon(
                                      Icons.add,
                                      color: Color.fromRGBO(251, 176, 59, 1),
                                    )
                                  : Icon(
                                      Icons.star,
                                      color: Color.fromRGBO(251, 176, 59, 1),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
