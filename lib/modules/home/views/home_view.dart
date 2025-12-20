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
  HomeView({super.key});

  final ApifyController controller = Get.find<ApifyController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Get.to(() => BarangView());
              break;
            case 3:
              Get.to(() => RecentActivityView());
              break;
            case 4:
              Get.to(() => ContactCardView());
              break;
          }
        },
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
            icon: SizedBox.shrink(),
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const HiveAddView()),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: CustomScrollView(
        slivers: [
          KecapAppBar(controller: controller),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const WelcomeCard(),
                  const SizedBox(height: 24),

                  const InventoryOverviewWidget(),
                  const SizedBox(height: 32),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      if (width >= 1000) {
                        return Row(
                          children: [
                            Expanded(child: _stokMasuk()),
                            const SizedBox(width: 16),
                            Expanded(child: _stokKeluar()),
                            const SizedBox(width: 16),
                            Expanded(child: _laporan()),
                            const SizedBox(width: 16),
                            Expanded(child: _analitik()),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _stokMasuk()),
                              const SizedBox(width: 16),
                              Expanded(child: _stokKeluar()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _laporan()),
                              const SizedBox(width: 16),
                              Expanded(child: _analitik()),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stokMasuk() => _FeatureCard(
        icon: Icons.arrow_downward,
        label: 'Stok Masuk',
        color: Colors.green,
        onTap: () => Get.to(() => const StockInView()),
      );

  Widget _stokKeluar() => _FeatureCard(
        icon: Icons.arrow_upward,
        label: 'Stok Keluar',
        color: Colors.red,
        onTap: () => Get.to(() => const StockOutView()),
      );

  Widget _laporan() => _FeatureCard(
        icon: Icons.receipt_long,
        label: 'Laporan Stok',
        color: Colors.blue,
        onTap: () => Get.to(() => StockReportView()),
      );

  Widget _analitik() => _FeatureCard(
        icon: Icons.analytics_outlined,
        label: 'Analitik',
        color: Colors.purple,
        onTap: () => Get.to(() => StockAnalyticsView()),
      );
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
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140, 
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
