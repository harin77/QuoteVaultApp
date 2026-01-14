import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'quotes/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'collections/collections_screen.dart';
import 'profile/profile_screen.dart';

/// Main app widget with bottom navigation
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;
  bool _darkMode = false;
  String _accentColor = AppConstants.defaultAccentColor;
  int _favoritesKey = 0;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool(AppConstants.darkModeKey) ?? false;
      _accentColor = prefs.getString(AppConstants.accentColorKey) ?? AppConstants.defaultAccentColor;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload theme when coming back to this screen
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.getLightTheme(_accentColor),
      darkTheme: AppTheme.getDarkTheme(_accentColor),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(key: ValueKey(_accentColor)),
            FavoritesScreen(key: ValueKey(_favoritesKey)),
            CollectionsScreen(),
            ProfileScreen(onThemeChanged: _loadTheme),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
              // Force reload favorites when switching to favorites tab
              if (index == 1) {
                _favoritesKey++;
              }
              // Reload theme when switching to profile tab
              if (index == 3) _loadTheme();
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Collections',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
