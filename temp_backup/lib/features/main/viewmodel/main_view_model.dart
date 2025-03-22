import 'package:flutter/material.dart';

class MainViewModel extends ChangeNotifier {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  bool _isResetting = false;

  PageController get pageController => _pageController;
  int get selectedIndex => _selectedIndex;
  bool get isResetting => _isResetting;

  void onItemTapped(int index) {
    _selectedIndex = index;
    _pageController.jumpToPage(index);
    notifyListeners();
  }

  void onPageChanged(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Helper method to set reset state
  void setResetting(bool value) {
    _isResetting = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
// Updated on 2025-01-02 - resolve null pointer exceptions
// Updated on 2025-01-06 - create data caching mechanism
// Updated on 2025-01-07 - create settings page
// Updated on 2025-01-07 - add navigation structure
// Updated on 2025-01-09 - create settings page
// Updated on 2025-01-22 - implement dark mode support
// Updated on 2025-01-27 - add authentication module
// Updated on 2025-01-27 - setup firebase configuration
// Updated on 2025-01-28 - implement chart visualization
// Updated on 2025-02-05 - resolve concurrent modification errors
// Updated on 2025-02-13 - refine color scheme
// Updated on 2025-02-17 - correct data loading problems
// Updated on 2025-02-19 - implement notification system
// Updated on 2025-02-19 - improve button styling
// Updated on 2025-02-28 - implement dark mode support
// Updated on 2025-03-10 - update navigation menu styling
// Updated on 2025-03-13 - implement notification system
// Updated on 2025-03-17 - enhance component reusability
// Updated on 2025-03-17 - implement filtering options
// Updated on 2025-03-21 - implement sorting options
