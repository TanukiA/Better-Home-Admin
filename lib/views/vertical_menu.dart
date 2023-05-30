import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class VerticalMenu extends StatefulWidget {
  final List<String> menuItems;
  final VoidCallback onLogout;

  const VerticalMenu({
    Key? key,
    required this.menuItems,
    required this.onLogout,
  }) : super(key: key);

  @override
  StateMVC<VerticalMenu> createState() => _VerticalMenuState();
}

class _VerticalMenuState extends StateMVC<VerticalMenu> {
  late String selectedMenuItem;

  @override
  void initState() {
    super.initState();
    selectedMenuItem = widget.menuItems.first;
  }

  void onMenuItemSelected(String menuItem) {
    setState(() {
      selectedMenuItem = menuItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle logoutBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.8, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    return Container(
      width: 200,
      color: Colors.blueGrey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var menuItem in widget.menuItems)
            GestureDetector(
              onTap: () => onMenuItemSelected(menuItem),
              child: Container(
                width: double.infinity,
                color: menuItem == selectedMenuItem
                    ? const Color.fromARGB(255, 121, 174, 96)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text(
                  menuItem,
                  style: TextStyle(
                    color: menuItem == selectedMenuItem
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton(
              style: logoutBtnStyle,
              onPressed: widget.onLogout,
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
