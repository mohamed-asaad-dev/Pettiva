import 'package:flutter/material.dart';

class AccountScreenItems extends StatelessWidget {
  const AccountScreenItems({
    super.key,
    required this.itemTitle,
    required this.itemIcon,
    required this.onPressed,
  });
  final String itemTitle;
  final Icon itemIcon;
  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: onPressed,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 10),
            itemIcon,
            SizedBox(width: 5),
            Text(
              itemTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
