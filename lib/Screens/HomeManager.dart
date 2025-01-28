import 'package:flutter/material.dart';
import 'package:app_001/Screens/map.dart';

class HomeManager extends StatefulWidget {
  const HomeManager({super.key});

  @override
  State<HomeManager> createState() => _HomeManagerState();
}

class _HomeManagerState extends State<HomeManager> {
  int _currentIndex = 0;
final List _screens = [
  map(),
  const about(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        
        currentIndex: _currentIndex,
        onTap: (index){
          setState(() {
            _currentIndex=index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: "About",
            ),
        ]
      ),
    );
  }
}

class about extends StatelessWidget {
  const about({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}