import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/screens/order_detail_page.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  String _filter = 'Aktif';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final filtered = _filteredOrders(provider.orders);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EC),
        title: const Text('Pesanan Saya'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchOrders,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            _buildFilter(),
            const SizedBox(height: 12),
            if (provider.isLoading && provider.orders.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && provider.orders.isEmpty)
              _buildError(provider)
            else if (filtered.isEmpty)
              _buildEmpty()
            else
              ...filtered.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOrderCard(order),
                  )),
          ],
        ),
      ),
    );
  }

  List<OrderModel> _filteredOrders(List<OrderModel> orders) {
    if (_filter == 'Selesai') {
      return orders.where((order) => order.isFinished).toList();
    }
    if (_filter == 'Ditolak') {
      return orders.where((order) => order.isRejected).toList();
    }
    return orders.where((order) => !order.isFinished && !order.isRejected).toList();
  }

  Widget _buildHeader(OrderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tracking Pesanan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${provider.totalOrders} total pesanan • ${provider.completedOrders} selesai', style: TextStyle(color: Colors.white.withValues(alpha: 0.70))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    final filters = ['Aktif', 'Selesai', 'Ditolak'];
    return Row(
      children: filters.map((filter) {
        final selected = _filter == filter;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Center(child: Text(filter)),
              selectedColor: const Color(0xFF1F1F1F),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF374151),
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide(color: selected ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB)),
              onSelected: (_) => setState(() => _filter = filter),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.055), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.14),
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
                      Expanded(child: Text(order.layanan, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
                      _statusChip(order.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(order.merkSepatu, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_currency(order.estimasiBiaya), style: const TextStyle(fontWeight: FontWeight.w800)),
                      if (order.hasRating) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF59E0B)),
                        Text('${order.rating}/5', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 72, color: Color(0xFF9CA3AF)),
          SizedBox(height: 12),
          Text('Belum ada pesanan di kategori ini.', style: TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildError(OrderProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 72, color: Colors.red),
          const SizedBox(height: 12),
          Text(provider.errorMessage ?? 'Gagal memuat data.', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: provider.fetchOrders, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
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
