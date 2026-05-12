import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettiva_v2/screens/account_screen.dart';
import 'screens/start_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int screenIndex = 0;

  void selectedScreen(int index) {
    setState(() {
      screenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = StartScreen(listLength: 1);
    if (screenIndex == 1) {
      screen = AccountScreen(getUserData: (userInformation) {});
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: Icon(Icons.logout),
          ),
        ],
        toolbarHeight: 75,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: Center(
          child: Image.asset(
            'assets/images/Pettiva.png',
            width: 300,
            height: 230,
            // color: const Color.fromRGBO(251, 176, 59, 1),
          ),
          // child: Text(
          //   'pettiva',
          //   style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          // ),
        ),
      ),
      body: screen,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.onPrimaryContainer,
                    Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withAlpha(75),
                  ],
                  begin: AlignmentGeometry.topCenter,
                  end: AlignmentGeometry.bottomCenter,
                ),
              ),
              child: Row(children: [Text('Pettiva')]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        onTap: selectedScreen,
        currentIndex: screenIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),

          BottomNavigationBarItem(
            label: 'Account',
            icon: Icon(Icons.account_box_outlined),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
