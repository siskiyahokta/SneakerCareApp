import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
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
        backgroundColor: const Color(0xFFFFF8EC),
        title: const Text(
          'Dashboard Vendor',
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
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
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
          colors: [Color(0xFF151515), Color(0xFF30261D), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.storefront_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sneakimy Care', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                    SizedBox(height: 2),
                    Text('Panel pemilik usaha', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Pantau foto sepatu customer, konfirmasi pesanan, dan kirim update status otomatis ke pelanggan.',
            style: TextStyle(color: Colors.white70, height: 1.45, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _miniHeaderStat('${provider.totalOrders}', 'Total'),
              _miniHeaderStat('${provider.processOrders}', 'Proses'),
              _miniHeaderStat('${provider.completedOrders}', 'Selesai'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniHeaderStat(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(OrderProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: [
        _statCard('Menunggu', provider.waitingOrders.toString(), Icons.schedule_rounded, const Color(0xFF64748B)),
        _statCard('Proses', provider.processOrders.toString(), Icons.autorenew_rounded, const Color(0xFFF59E0B)),
        _statCard('Selesai', provider.completedOrders.toString(), Icons.check_circle_rounded, const Color(0xFF16A34A)),
        _statCard('Ditolak', provider.rejectedOrdersCount.toString(), Icons.cancel_rounded, const Color(0xFFDC2626)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    final filters = ['Semua', ...OrderModel.adminStatuses];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final status = filters[index];
          final selected = status == _selectedStatus;
          final color = status == 'Semua' ? const Color(0xFF1F1F1F) : _statusColor(status);

          return ChoiceChip(
            label: Text(status),
            selected: selected,
            selectedColor: color,
            backgroundColor: Colors.white,
            side: BorderSide(color: color.withValues(alpha: 0.26)),
            labelStyle: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w900,
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
    final color = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminOrderDetailPage(orderId: order.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _orderImage(order),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.merkSepatu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ),
                        _statusPill(order.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.customerName.isEmpty ? order.customerEmail : order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.design_services_rounded, size: 16, color: color),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            order.layanan,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: order.isRejected ? 1 : order.progressValue,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.payments_rounded, size: 15, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(order.formattedPrice, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderImage(OrderModel order) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 76,
        height: 92,
        color: const Color(0xFFFFF3D6),
        child: order.hasPhoto
            ? Image.network(
                order.shoePhotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_rounded, color: Color(0xFFF59E0B)),
              )
            : const Icon(Icons.photo_camera_back_rounded, color: Color(0xFFF59E0B), size: 32),
      ),
    );
  }

  Widget _statusPill(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_rounded, size: 56, color: Colors.grey),
          SizedBox(height: 10),
          Text('Belum ada pesanan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          SizedBox(height: 6),
          Text('Pesanan customer akan tampil di sini.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF16A34A);
      case 'ditolak':
        return const Color(0xFFDC2626);
      case 'dijemput kurir':
      case 'cleaning':
      case 'drying':
      case 'packing':
        return const Color(0xFFF59E0B);
      case 'menunggu kurir':
      default:
        return const Color(0xFF64748B);
    }
  }
}
