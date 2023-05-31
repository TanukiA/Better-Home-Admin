import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class VerticalMenu extends StatefulWidget {
  const VerticalMenu({
    Key? key,
    required this.loginCon,
  }) : super(key: key);

  final LoginController loginCon;

  @override
  StateMVC<VerticalMenu> createState() => _VerticalMenuState();
}

class _VerticalMenuState extends StateMVC<VerticalMenu> {
  late String selectedMenuItem;

  final List<String> menuItems = [
    'Dashboard',
    'User Accounts',
    'Registration Requests',
    'Ongoing & Completed Services',
    'Cancelled Services',
    "Technician Reviews",
  ];

  @override
  void initState() {
    super.initState();
    selectedMenuItem = menuItems.first;
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
      fixedSize: Size(size.width * 0.55, 38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    return Container(
      width: 250,
      color: const Color(0xFF887C3F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var menuItem in menuItems)
            GestureDetector(
              onTap: () => onMenuItemSelected(menuItem),
              child: Container(
                width: double.infinity,
                color: menuItem == selectedMenuItem
                    ? const Color.fromARGB(255, 176, 185, 112)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text(
                  menuItem,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton(
              style: logoutBtnStyle,
              onPressed: () => widget.loginCon.logoutClicked(context),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
