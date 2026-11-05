import 'package:flutter/material.dart';

import '../aquarium/aquarium_screen.dart';
import '../catches/catches_screen.dart';
import '../map/map_screen.dart';
import '../settings/settings_screen.dart';

/// The main frame: a bottom bar to switch screens and a button to add a catch.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0; // which tab is selected: 0 = Aquarium

  static const _screens = <Widget>[
    AquariumScreen(),
    CatchesScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Milestone 2: open the add-catch form here.
        },
        icon: const Icon(Icons.add),
        label: const Text('Add catch'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.water), label: 'Aquarium'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Catches'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}