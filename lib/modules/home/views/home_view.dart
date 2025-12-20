import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/modules/apify/controllers/apify_controller.dart';
import 'package:my_app/modules/auth/controllers/auth_controller.dart';
import 'package:my_app/routes/app_routes.dart';

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
  final AuthController authController = Get.find<AuthController>();

  HomeView({super.key});

  void _showLoginPrompt(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Login Diperlukan'),
        content: const Text('Anda harus login untuk mengakses fitur ini.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final isLoggedIn = authController.isLoggedIn.value;

      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        resizeToAvoidBottomInset: false,
        // AppBar removed to avoid duplicate title — `KecapAppBar` (SliverAppBar) is used instead
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          padding: EdgeInsets.zero,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                icon: Icon(Icons.location_on_outlined),
                label: 'Lokasi',
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
                  break;
                case 1:
                  if (!isLoggedIn) {
                    _showLoginPrompt(context);
                  } else {
                    Get.to(() => BarangView());
                  }
                  break;
                case 2:
                  if (!isLoggedIn) {
                    _showLoginPrompt(context);
                  } else {
                    Get.toNamed(AppRoutes.location);
                  }
                  break;
                case 3:
                  if (!isLoggedIn) {
                    _showLoginPrompt(context);
                  } else {
                    Get.to(() => RecentActivityView());
                  }
                  break;
                case 4:
                  if (!isLoggedIn) {
                    _showLoginPrompt(context);
                  } else {
                    Get.to(() => ContactCardView());
                  }
                  break;
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (!isLoggedIn) {
              _showLoginPrompt(context);
            } else {
              Get.to(() => const HiveAddView());
            }
          },
          tooltip: 'Tambah Produk',
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: CustomScrollView(
          slivers: [
            KecapAppBar(controller: controller),

            // CONTENT
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // WELCOME
                  WelcomeCard(),
                  const SizedBox(height: 32),

                  // Show inventory only when logged in
                  if (isLoggedIn) ...[
                    const InventoryOverviewWidget(),
                    const SizedBox(height: 32),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(
                          (0.3 * 255).round(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withAlpha(
                            (0.3 * 255).round(),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Fitur Terbatas',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Login untuk mengakses semua fitur aplikasi',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // FEATURE CARDS (3x2 Grid)
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _FeatureCard(
                        icon: Icons.arrow_downward,
                        label: 'Stok Masuk',
                        color: Colors.green,
                        isEnabled: isLoggedIn,
                        onTap: () {
                          if (!isLoggedIn) {
                            _showLoginPrompt(context);
                          } else {
                            Get.to(() => const StockInView());
                          }
                        },
                      ),
                      _FeatureCard(
                        icon: Icons.arrow_upward,
                        label: 'Stok Keluar',
                        color: Colors.red,
                        isEnabled: isLoggedIn,
                        onTap: () {
                          if (!isLoggedIn) {
                            _showLoginPrompt(context);
                          } else {
                            Get.to(() => const StockOutView());
                          }
                        },
                      ),
                      _FeatureCard(
                        icon: Icons.receipt_long,
                        label: 'Laporan Stok',
                        color: Colors.blue,
                        isEnabled: isLoggedIn,
                        onTap: () {
                          if (!isLoggedIn) {
                            _showLoginPrompt(context);
                          } else {
                            Get.to(() => StockReportView());
                          }
                        },
                      ),
                      _FeatureCard(
                        icon: Icons.analytics_outlined,
                        label: 'Analitik',
                        color: Colors.purple,
                        isEnabled: isLoggedIn,
                        onTap: () {
                          if (!isLoggedIn) {
                            _showLoginPrompt(context);
                          } else {
                            Get.to(() => StockAnalyticsView());
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Space for FAB and navigation
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isEnabled ? 1.0 : 0.5;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled ? Colors.grey[200]! : Colors.grey[300]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha((0.1 * 255).round()),
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
              if (!isEnabled)
                Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[400],
                      size: 24,
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
