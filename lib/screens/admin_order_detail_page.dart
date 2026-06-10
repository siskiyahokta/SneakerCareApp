import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/services/api_service.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class AdminOrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const AdminOrderDetailPage({super.key, required this.order});

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _statuses = const [
    'Menunggu Kurir',
    'Dijemput Kurir',
    'Cleaning',
    'Drying',
    'Packing',
    'Selesai',
    'Ditolak',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final order = provider.orders.firstWhere(
      (item) => item.id == widget.order.id,
      orElse: () => widget.order,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text('Detail Vendor'),
        backgroundColor: const Color(0xFFFFF8EC),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchOrders,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHeader(order),
            const SizedBox(height: 16),
            _buildCustomerCard(order),
            const SizedBox(height: 16),
            _buildPhotoCard(order),
            const SizedBox(height: 16),
            _buildStatusAction(order, provider),
            const SizedBox(height: 16),
            _buildRatingCard(order),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF2D2417)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.layanan, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Order #${order.id}', style: TextStyle(color: Colors.white.withValues(alpha: 0.70))),
                  ],
                ),
              ),
              _statusChip(order.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _headerMetric('Biaya', _currency(order.estimasiBiaya)),
              const SizedBox(width: 12),
              _headerMetric('Rating', order.rating == 0 ? '-' : '${order.rating}/5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerMetric(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Customer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _infoRow(Icons.person_rounded, 'Nama', order.customerName.isEmpty ? '-' : order.customerName),
          _infoRow(Icons.email_rounded, 'Email', order.customerEmail.isEmpty ? '-' : order.customerEmail),
          _infoRow(Icons.directions_walk_rounded, 'Alamat Pickup', order.alamatPickup),
          _infoRow(Icons.checkroom_rounded, 'Merk Sepatu', order.merkSepatu),
          _infoRow(Icons.texture_rounded, 'Bahan', order.bahanSepatu),
          _infoRow(Icons.note_alt_rounded, 'Catatan', order.catatan.isEmpty ? '-' : order.catatan),
          if (order.rejectionReason.isNotEmpty)
            _infoRow(Icons.warning_rounded, 'Alasan Ditolak', order.rejectionReason),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(OrderModel order) {
    final image = ApiService.imageUrl(order.shoePhoto);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Foto Sepatu Customer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: image.isEmpty
                ? Container(
                    height: 210,
                    width: double.infinity,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(child: Text('Customer belum upload foto')),
                  )
                : Image.network(
                    image,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 210,
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(child: Text('Foto tidak bisa dimuat')),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAction(OrderModel order, OrderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Status Pesanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses.map((status) {
              final selected = status.toLowerCase() == order.status.toLowerCase();
              final color = _statusColor(status);
              return ChoiceChip(
                selected: selected,
                label: Text(status),
                selectedColor: color.withValues(alpha: 0.20),
                backgroundColor: const Color(0xFFF9FAFB),
                labelStyle: TextStyle(
                  color: selected ? color : const Color(0xFF374151),
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
                side: BorderSide(color: selected ? color : const Color(0xFFE5E7EB)),
                onSelected: provider.isLoading ? null : (_) => _handleStatus(order, provider, status),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rating & Ulasan Customer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (!order.hasRating)
            const Text('Customer belum memberikan rating.', style: TextStyle(color: Color(0xFF6B7280)))
          else ...[
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star_rounded,
                  color: i < order.rating ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                  size: 30,
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              order.review.isEmpty ? 'Tidak ada komentar.' : order.review,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleStatus(OrderModel order, OrderProvider provider, String status) async {
    String reason = '';

    if (status == 'Ditolak') {
      _reasonController.clear();
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alasan Penolakan'),
            content: TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Area pickup di luar jangkauan / data kurang lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(onPressed: () => Navigator.pop(context, _reasonController.text.trim()), child: const Text('Simpan')),
            ],
          );
        },
      );
      if (result == null) return;
      reason = result.isEmpty ? 'Pesanan ditolak oleh pemilik usaha.' : result;
    }

    final success = await provider.updateStatus(
      id: order.id,
      status: status,
      customerEmail: order.customerEmail,
      rejectionReason: reason,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Status berhasil diperbarui menjadi $status.' : provider.errorMessage ?? 'Gagal update status.'),
        backgroundColor: success ? const Color(0xFF059669) : Colors.red,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          SizedBox(width: 105, child: Text(label, style: const TextStyle(color: Color(0xFF6B7280)))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8))],
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'selesai') return const Color(0xFF059669);
    if (s == 'ditolak') return const Color(0xFFDC2626);
    if (s == 'menunggu kurir') return const Color(0xFF6B7280);
    return const Color(0xFFF59E0B);
  }

  String _currency(int value) {
    final text = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $text';
  }
}
