import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/modules/apify/controllers/apify_controller.dart';

// widgets
import '../../../shared/widgets/kecap_app_bar.dart';
import '../../../shared/widgets/welcome_card.dart';
import '../../product/widgets/inventory_overview_widget.dart';
import '../../product/views/stok/stock_in_view.dart';
import '../../product/views/stok/stock_out_view.dart';
import '../../product/views/stok/stock_report_view.dart';
import '../../product/views/stok/stock_analytics_view.dart';
import '../../product/views/barang_view.dart';
import '../../product/views/recent_activity_view.dart';
import '../../product/views/hive/hive_add_view.dart';
import '../../contact/views/contact_card_view.dart';

class HomeView extends StatelessWidget {
  final ApifyController controller = Get.find<ApifyController>();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Barang',
            ),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(), // Space for FAB
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: 'Kontak',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                // Stay on Home
                break;
              case 1:
                Get.to(() => BarangView());
                break;
              case 2:
                // Skip FAB center
                break;
              case 3:
                Get.to(() => RecentActivityView());
                break;
              case 4:
                Get.to(() => ContactCardView());
                break;
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const HiveAddView()),
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: CustomScrollView(
        slivers: [
          KecapAppBar(controller: controller),

          // CONTENT
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // WELCOME
                WelcomeCard(),
                const SizedBox(height: 24),

                // INVENTORY OVERVIEW
                const InventoryOverviewWidget(),
                const SizedBox(height: 32),

                // FEATURE CARDS (3x2 Grid)
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _FeatureCard(
                      icon: Icons.arrow_downward,
                      label: 'Stok Masuk',
                      color: Colors.green,
                      onTap: () => Get.to(() => const StockInView()),
                    ),
                    _FeatureCard(
                      icon: Icons.arrow_upward,
                      label: 'Stok Keluar',
                      color: Colors.red,
                      onTap: () => Get.to(() => const StockOutView()),
                    ),
                    _FeatureCard(
                      icon: Icons.receipt_long,
                      label: 'Laporan Stok',
                      color: Colors.blue,
                      onTap: () => Get.to(() => StockReportView()),
                    ),
                    _FeatureCard(
                      icon: Icons.analytics_outlined,
                      label: 'Analitik',
                      color: Colors.purple,
                      onTap: () => Get.to(() => StockAnalyticsView()),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
