import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/admin_order_detail_page.dart';
import 'package:sneaker_care_app/screens/landing_page.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
      (route) => false,
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedStatus == 'Semua') return orders;
    return orders.where((order) => order.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard Pemilik',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => Provider.of<OrderProvider>(context, listen: false).fetchOrders(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final orders = _filterOrders(provider.pesananList);

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOrders(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              children: [
                _buildHeader(provider),
                const SizedBox(height: 16),
                _buildStats(provider),
                const SizedBox(height: 18),
                _buildFilter(),
                const SizedBox(height: 14),
                if (provider.errorMessage != null) _buildError(provider.errorMessage!),
                if (orders.isEmpty) _buildEmpty(),
                ...orders.map(_buildOrderCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OrderProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1F1F), Color(0xFF3B2F2F), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sneakimy Care',
            style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelola pesanan customer, update status pengerjaan, dan pantau order masuk.',
            style: TextStyle(color: Colors.white70, height: 1.45, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            '${provider.totalOrders} total pesanan',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(OrderProvider provider) {
    return Row(
      children: [
        _statCard('Menunggu', provider.waitingOrders.toString(), Icons.schedule_rounded),
        const SizedBox(width: 10),
        _statCard('Proses', provider.processOrders.toString(), Icons.autorenew_rounded),
        const SizedBox(width: 10),
        _statCard('Selesai', provider.completedOrders.toString(), Icons.check_circle_rounded),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    final filters = ['Semua', ...OrderModel.statusFlow];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final status = filters[index];
          final selected = status == _selectedStatus;
          return ChoiceChip(
            label: Text(status),
            selected: selected,
            selectedColor: const Color(0xFFF59E0B),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF1F1F1F),
              fontWeight: FontWeight.w800,
            ),
            onSelected: (_) => setState(() => _selectedStatus = status),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminOrderDetailPage(orderId: order.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFF59E0B)),
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
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      order.customerName.isEmpty ? order.customerEmail : order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _badge(order.status),
                        Text(
                          order.layanan,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
      child: Text(message, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: const Column(
        children: [
          Icon(Icons.inbox_rounded, color: Colors.grey, size: 58),
          SizedBox(height: 12),
          Text('Belum ada pesanan pada filter ini.', style: TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
