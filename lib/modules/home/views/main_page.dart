import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:my_app/modules/home/views/home_view.dart';
import 'package:my_app/modules/product/views/barang_view.dart';
import 'package:my_app/modules/product/views/recent_activity_view.dart';
import 'package:my_app/modules/contact/views/contact_card_view.dart';
import 'package:my_app/modules/product/views/hive/hive_add_view.dart';
import 'package:my_app/modules/contact/views/add_contact_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
          HomeView(),
          BarangView(),
          RecentActivityView(),
          ContactCardView(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_currentIndex) {
            case 1:
              Get.to(() => const HiveAddView());
              break;
            case 3:
              Get.to(() => AddContactView());
              break;
            default:
              return;
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Barang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Kontak'),
        ],
      ),
    );
  }
}
