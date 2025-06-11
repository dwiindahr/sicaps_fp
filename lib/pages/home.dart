import 'package:flutter/material.dart';
import 'meccabot.dart';
import 'tracker.dart';
import 'settings.dart';
import '/widgets/navbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(), 
    MeccaChatsPage(),
    LiveTrackerPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DestinationCard(
            title: 'Telusuri Kota Makkah',
            imagePath: 'assets/images/makkah.webp', 
            onTap: () {

            },
          ),
          SizedBox(height: 16),
          DestinationCard(
            title: 'Ziarah Masjid Nabawi',
            imagePath: 'assets/images/madinah.webp', 
            onTap: () {

            },
          ),
          SizedBox(height: 16),
          DestinationCard(
            title: 'Singgah Jeddah',
            imagePath: 'assets/images/jeddah.jpg',
            onTap: () {
              
            },
          ),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const DestinationCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: SizedBox(
        height: 100, 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}