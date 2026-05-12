import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pettiva_v2/models/order_details.dart';

import 'package:pettiva_v2/screens/pet_walking_screen.dart';

class OrderSummaryScreen extends ConsumerStatefulWidget {
  const OrderSummaryScreen({super.key});

  // final void Function(int lengthList) lengthOrderList;

  @override
  ConsumerState<OrderSummaryScreen> createState() {
    return OrderSummaryScreenState();
  }
}

class OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  List<OrderDetails> listOrders = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', whereIn: ['accepted', 'posted'])
          .get();

      for (final doc in response.docs) {
        final data = doc.data();
        if (FirebaseAuth.instance.currentUser!.uid == data['userId']) {
          setState(() {
            listOrders.add(
              OrderDetails(
                data['serviceType'],

                // data['userId'],
                data['status'],
                data['address'],
                data['buildingNumber'],
                data['floorNumber'],
                (data['date'] as Timestamp).toDate(),
                parseTime(data['time']),
              ),
            );
          });
        }
      }
      // widget.lengthOrderList(listOrders.length);
    } catch (e) {
      print('Load orders error: $e');
    }
  }

  TimeOfDay parseTime(String timeString) {
    final timeParts = timeString.split(' ');

    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    final period = timeParts[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: Text(
          'Ongoing Requests',
          style: TextStyle(color: Color.fromRGBO(251, 176, 59, 1)),
        ),
      ),
      body: ListView(
        children: [
          for (final order in listOrders)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 120,

                child: Card(
                  elevation: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: ListTile(
                    leading: order.status == 'posted'
                        ? const Icon(
                            Icons.send_rounded,
                            color: Color.fromRGBO(251, 176, 59, 1),
                          )
                        : const Icon(
                            Icons.delivery_dining,
                            color: Color.fromARGB(255, 146, 186, 255),
                          ),
                    title: order.status == 'posted'
                        ? Text(
                            'Your order has been posted',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 196, 242, 197),
                              fontSize: 18,
                            ),
                          )
                        : Text(
                            'Your walker is on the way',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 146, 186, 255),
                            ),
                          ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.addressDetails +
                              ', Building Number: ' +
                              order.buildingNumber +
                              ', Floor Number: ' +
                              order.floorNumber +
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
                              order.selectedDate.toString().substring(5, 9),
                              style: TextStyle(
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
                              order.selectedTime.toString().substring(10, 15),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Spacer(),
                            order.serviceType == 'standard'
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
            ),
        ],
      ),
    );
  }
}
