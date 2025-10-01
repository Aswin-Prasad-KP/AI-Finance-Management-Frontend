import 'package:flutter/material.dart';

import './mock_dashboard_screen.dart';
import './mock_settings_screen.dart';
import './mock_transactions_screen.dart';
import './mock_budgets_screen.dart';
import './mock_add_transaction_modal.dart'; // Import the new modal

// Create a GlobalKey to access the MainScreen's state from other widgets.
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // We need the key on the state, not the widget
  @override
  void initState() {
    super.initState();
    // Assign the key to this state object
    mainScreenKey.currentState?.dispose(); // Dispose old state if any
  }

  // Expose a method to be called from the global key
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    MockSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        // Assign a unique heroTag to prevent animation conflicts
        heroTag: 'add_transaction_fab',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', index: 0),
            _buildNavItem(icon: Icons.list_alt_rounded, label: 'Transactions', index: 1),
            const SizedBox(width: 48), // The space for the FAB
            _buildNavItem(icon: Icons.pie_chart_rounded, label: 'Budgets', index: 2),
            _buildNavItem(icon: Icons.settings_rounded, label: 'Settings', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}

