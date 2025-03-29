import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/constants/padding_constants.dart';
import 'package:vilsa/core/extensions/context_extension.dart';
import 'package:vilsa/features/home/view/home_view.dart';
import 'package:vilsa/features/main/viewmodel/main_view_model.dart';
import 'package:vilsa/features/stock/view/stock_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          drawer: _buildDrawer(context, viewModel),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(MainViewModel viewModel) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: viewModel.pageController,
              onPageChanged: viewModel.onPageChanged,
              children: const [
                HomeView(),
                StockView(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildCustomNavBar(viewModel),
        ),
      ],
    );
  }

  /// Builds the custom navigation bar with a single navigation item.
  Widget _buildCustomNavBar(MainViewModel viewModel) {
    return Container(
      height: 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(
            icon: Icons.home_filled,
            index: 0,
            selectedIndex: viewModel.selectedIndex,
            onTap: () => viewModel.onItemTapped(0),
            context: context,
          ),
          _buildNavBarItem(
            icon: Icons.monitor_heart, // Icon for StockView
            index: 1, // Index for StockView
            selectedIndex: viewModel.selectedIndex,
            onTap: () => viewModel.onItemTapped(1),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required int index,
    required int selectedIndex,
    required Function() onTap,
    required BuildContext context,
  }) {
    final isSelected = index == selectedIndex;
    final iconColor = isSelected ? context.primary : context.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: PaddingConstants.allSmall,
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 30),
          ],
        ),
      ),
    );
  }

  // Add a drawer with settings and reset options
  Widget _buildDrawer(BuildContext context, MainViewModel viewModel) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vilsa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Portföy Yönetimi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.restore),
            title: Text('Örnek Verileri Yükle'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showImportDataDialog(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Hakkında'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showImportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Örnek Verileri Yükle'),
        content: const Text(
          'Bu işlem mevcut verileri silecek ve örnek verilerle değiştirecektir. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Access the HomeViewModel to import sample data
            },
            child: const Text('Yükle'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hakkında'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vilsa - Portföy Yönetimi'),
            SizedBox(height: 8),
            Text('Sürüm: 1.0.0'),
            SizedBox(height: 16),
            Text('Türk borsası için portföy takip ve analizi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
// Updated on 2025-01-02 - resolve null pointer exceptions
// Updated on 2025-01-06 - create data caching mechanism
// Updated on 2025-01-07 - create settings page
// Updated on 2025-01-07 - add navigation structure
// Updated on 2025-01-09 - create settings page
// Updated on 2025-01-27 - add authentication module
// Updated on 2025-01-27 - setup firebase configuration
// Updated on 2025-01-28 - implement chart visualization
// Updated on 2025-02-05 - resolve concurrent modification errors
// Updated on 2025-02-13 - refine color scheme
// Updated on 2025-02-19 - improve button styling
// Updated on 2025-02-28 - implement dark mode support
// Updated on 2025-03-10 - update navigation menu styling
// Updated on 2025-03-13 - implement notification system
// Updated on 2025-03-17 - enhance component reusability
// Updated on 2025-03-17 - implement filtering options
// Updated on 2025-03-21 - implement sorting options
