import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/screens/edit_order_page.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Future<void> _cancelOrder(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Pesanan hanya bisa dibatalkan saat status masih Menunggu Kurir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Batalkan')),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final success = await provider.hapusPesanan(order.id, customerEmail: auth.email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Pesanan berhasil dibatalkan.' : provider.errorMessage ?? 'Gagal membatalkan pesanan.'),
        backgroundColor: success ? const Color(0xFF16A34A) : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final order = provider.getOrderById(widget.orderId);

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pesanan')),
            body: const Center(child: Text('Pesanan tidak ditemukan.')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8EC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF8EC),
            title: const Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              _buildPhoto(order),
              const SizedBox(height: 16),
              _buildProgress(order),
              const SizedBox(height: 16),
              _buildInfo(order),
              const SizedBox(height: 18),
              if (order.canEdit) _buildActions(order),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoto(OrderModel order) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 240,
        color: const Color(0xFFFFF3D6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (order.hasPhoto)
              Image.network(
                order.shoePhotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _emptyPhoto(),
              )
            else
              _emptyPhoto(),
            Positioned(left: 14, top: 14, child: _statusPill(order.status)),
          ],
        ),
      ),
    );
  }

  Widget _emptyPhoto() {
    return const Center(
      child: Icon(Icons.photo_camera_back_rounded, size: 62, color: Color(0xFFF59E0B)),
    );
  }

  Widget _buildProgress(OrderModel order) {
    final color = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: order.isRejected ? 1 : order.progressValue,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            order.isRejected ? 'Pesanan ditolak oleh pemilik usaha.' : 'Status saat ini: ${order.status}',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          if (order.isRejected && order.rejectionReason.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Alasan: ${order.rejectionReason}', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfo(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.merkSepatu, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _infoRow(Icons.design_services_rounded, 'Layanan', order.layanan),
          _infoRow(Icons.category_rounded, 'Bahan', order.bahanSepatu),
          _infoRow(Icons.payments_rounded, 'Estimasi', order.formattedPrice),
          _infoRow(Icons.location_on_rounded, 'Alamat Pickup', order.alamatPickup),
          if (order.catatan.trim().isNotEmpty) _infoRow(Icons.edit_note_rounded, 'Catatan', order.catatan),
        ],
      ),
    );
  }

  Widget _buildActions(OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditOrderPage(order: order)),
              );
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _cancelOrder(order),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            icon: const Icon(Icons.cancel_rounded),
            label: const Text('Batalkan'),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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
      default:
        return const Color(0xFF64748B);
    }
  }
}
