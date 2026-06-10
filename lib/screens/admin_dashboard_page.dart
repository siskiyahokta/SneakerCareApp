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
  String _filter = 'Semua';

  final List<String> _filters = const [
    'Semua',
    'Menunggu',
    'Proses',
    'Selesai',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<OrderProvider>(context);
    final filteredOrders = _filtered(provider.orders);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.fetchOrders,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: _buildHeader(auth),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: _buildStats(provider),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: _buildFilter(),
                ),
              ),
              if (provider.isLoading && provider.orders.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null && provider.orders.isEmpty)
                SliverFillRemaining(child: _buildError(provider))
              else if (filteredOrders.isEmpty)
                SliverFillRemaining(child: _buildEmpty())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = filteredOrders[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(18, index == 0 ? 16 : 8, 18, 8),
                        child: _buildOrderCard(order),
                      );
                    },
                    childCount: filteredOrders.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF4A2E0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Pemilik', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    SizedBox(height: 2),
                    Text('Kelola pesanan Sneakimy Care', style: TextStyle(color: Color(0xFFD1D5DB))),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LandingPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Color(0xFFFBBF24)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Update status tepat waktu agar customer mendapat notifikasi dan progress real-time.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(OrderProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            _statCard('Total', provider.totalOrders.toString(), Icons.receipt_long_rounded, const Color(0xFF111827)),
            const SizedBox(width: 10),
            _statCard('Proses', provider.processOrders.toString(), Icons.sync_rounded, const Color(0xFFF59E0B)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard('Selesai', provider.completedOrders.toString(), Icons.check_circle_rounded, const Color(0xFF059669)),
            const SizedBox(width: 10),
            _statCard('Ditolak', provider.rejectedOrders.toString(), Icons.cancel_rounded, const Color(0xFFDC2626)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rata-rata Rating', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                    Text(
                      provider.averageRating == 0 ? 'Belum ada rating' : '${provider.averageRating.toStringAsFixed(1)} / 5.0',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final selected = filter == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter),
              selectedColor: const Color(0xFF1F1F1F),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF374151),
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide(color: selected ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB)),
              onSelected: (_) => setState(() => _filter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminOrderDetailPage(order: order)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(_statusIcon(order.status), color: _statusColor(order.status)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(order.layanan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      _statusChip(order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(order.customerName.isEmpty ? order.customerEmail : order.customerName, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${order.merkSepatu} • ${_currency(order.estimasiBiaya)}', style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  List<OrderModel> _filtered(List<OrderModel> orders) {
    switch (_filter) {
      case 'Menunggu':
        return orders.where((o) => o.isWaiting).toList();
      case 'Proses':
        return orders.where((o) => o.isInProgress).toList();
      case 'Selesai':
        return orders.where((o) => o.isFinished).toList();
      case 'Ditolak':
        return orders.where((o) => o.isRejected).toList();
      default:
        return orders;
    }
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 70, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text('Belum ada pesanan pada filter ini.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(OrderProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 70, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            Text(provider.errorMessage ?? 'Gagal memuat data.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: provider.fetchOrders, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w900)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.055), blurRadius: 16, offset: const Offset(0, 8))],
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'selesai') return const Color(0xFF059669);
    if (s == 'ditolak') return const Color(0xFFDC2626);
    if (s == 'menunggu kurir') return const Color(0xFF6B7280);
    return const Color(0xFFF59E0B);
  }

  IconData _statusIcon(String status) {
    final s = status.toLowerCase();
    if (s == 'selesai') return Icons.check_circle_rounded;
    if (s == 'ditolak') return Icons.cancel_rounded;
    if (s == 'menunggu kurir') return Icons.hourglass_empty_rounded;
    return Icons.sync_rounded;
  }

  String _currency(int value) {
    final text = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $text';
  }
}
