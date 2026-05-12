import 'package:flutter/material.dart';
import '../data/fun_facts_data.dart';
import 'dart:async';

class FunFactsCards extends StatefulWidget {
  const FunFactsCards({super.key});

  @override
  State<FunFactsCards> createState() => _FunFactsCardsState();
}

class _FunFactsCardsState extends State<FunFactsCards>
    with SingleTickerProviderStateMixin {
  late List shuffledList;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    shuffledList = [...data];

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        shuffledList.shuffle();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shuffledList.length,
            itemBuilder: (context, index) {
              final item = shuffledList[index];

              return Padding(
                padding: const EdgeInsets.all(12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.5, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: SizedBox(
                    key: ValueKey(item.label),
                    width: 390,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(35),
                      ),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      child: ListTile(
                        leading: Image.asset(item.image),
                        title: Text(
                          item.label,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: const Color.fromRGBO(251, 176, 59, 1),
                              ),
                        ),
                        subtitle: Text(
                          item.information + item.tip,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
