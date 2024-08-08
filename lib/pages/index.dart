import 'package:flutter/material.dart';
import 'package:freshveggie/tabs/bag_tab.dart';
import 'package:freshveggie/tabs/home_tab.dart';
import 'package:freshveggie/tabs/profile_tab.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _HomePageState();
}

class _HomePageState extends State<Index> {
  int currentPageIndex = 0;
  final List<Widget> _screens = const [
    HomeTab(),
    BagTab(),
    ProfileTab(),
  ];

  void onDestinationSelected(int selectedIndex) {
    setState(() {
      currentPageIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: theme.secondaryContainer,
      body: _screens.elementAt(currentPageIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const <Widget>[
          NavigationDestination(
            enabled: true,
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            enabled: true,
            selectedIcon: Icon(Icons.shopping_bag),
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Bag',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        indicatorColor: theme.onSecondary,
      ),
    );
  }
}
