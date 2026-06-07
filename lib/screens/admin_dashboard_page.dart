import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/admin_order_detail_page.dart';
import 'package:sneaker_care_app/screens/landing_page.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LandingPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.fetchOrders,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildAdminHeader(provider),
                const SizedBox(height: 22),

                const Text(
                  "Pesanan Masuk",
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Admin bertugas mengubah status progress pengerjaan pesanan customer.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),

                if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (provider.pesananList.isEmpty)
                  _buildEmptyState()
                else
                  ...provider.pesananList.map((order) {
                    return _AdminOrderCard(order: order);
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminHeader(OrderProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F1F1F),
            Color(0xFF3B2F2F),
            Color(0xFFF59E0B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mode Admin",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Sneakimy Care",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${provider.totalPesanan} total pesanan",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Colors.grey,
            size: 80,
          ),
          SizedBox(height: 16),
          Text(
            "Belum ada pesanan masuk.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const _AdminOrderCard({
    required this.order,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF059669);
      case 'Cleaning':
      case 'Drying':
      case 'Packing':
        return const Color(0xFFF59E0B);
      case 'Dijemput Kurir':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminOrderDetailPage(
                  orderId: order.id,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
              color: Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.directions_run_rounded,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.merkSepatu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1F1F1F),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        order.layanan,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}