import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class AdminOrderDetailPage extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailPage({super.key, required this.orderId});

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  String? _selectedStatus;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(OrderModel order) async {
    if (_selectedStatus == null || _selectedStatus == order.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih status baru terlebih dahulu.')),
      );
      return;
    }

    if (_selectedStatus == OrderModel.rejectedStatus && _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan penolakan wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final success = await provider.updateStatus(
      id: order.id,
      status: _selectedStatus!,
      rejectionReason: _reasonController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status berhasil diubah dan notifikasi dikirim.'
              : provider.errorMessage ?? 'Status gagal diubah.',
        ),
        backgroundColor: success ? const Color(0xFF16A34A) : Colors.red,
      ),
    );

    if (success) {
      setState(() => _selectedStatus = null);
    }
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
            title: const Text('Detail Vendor', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              _buildPhoto(order),
              const SizedBox(height: 16),
              _buildMainCard(order),
              const SizedBox(height: 16),
              _buildCustomerCard(order),
              const SizedBox(height: 16),
              _buildStatusCard(order, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoto(OrderModel order) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
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
            Positioned(
              left: 14,
              top: 14,
              child: _statusPill(order.status),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_camera_back_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        order.hasPhoto ? 'Foto sepatu dari customer' : 'Customer belum mengirim foto sepatu',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyPhoto() {
    return Container(
      color: const Color(0xFFFFF3D6),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded, size: 62, color: Color(0xFFF59E0B)),
      ),
    );
  }

  Widget _buildMainCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.merkSepatu, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _infoRow(Icons.design_services_rounded, 'Layanan', order.layanan),
          _infoRow(Icons.category_rounded, 'Bahan', order.bahanSepatu),
          _infoRow(Icons.payments_rounded, 'Estimasi', order.formattedPrice),
          _infoRow(Icons.location_on_rounded, 'Alamat Pickup', order.alamatPickup),
          if (order.catatan.trim().isNotEmpty) _infoRow(Icons.edit_note_rounded, 'Catatan', order.catatan),
          if (order.isRejected && order.rejectionReason.trim().isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Alasan ditolak: ${order.rejectionReason}',
                style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _infoRow(Icons.person_rounded, 'Nama', order.customerName.isEmpty ? '-' : order.customerName),
          _infoRow(Icons.email_rounded, 'Email', order.customerEmail.isEmpty ? '-' : order.customerEmail),
        ],
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order, OrderProvider provider) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Status Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text(
            'Setiap perubahan status akan disimpan ke halaman notifikasi customer dan dikirim lewat FCM jika token tersedia.',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OrderModel.adminStatuses.map((status) {
              final selected = _selectedStatus == status;
              final current = order.status == status;
              final color = _statusColor(status);
              return ChoiceChip(
                label: Text(current ? '$status • aktif' : status),
                selected: selected,
                selectedColor: color,
                disabledColor: color.withValues(alpha: 0.12),
                backgroundColor: Colors.white,
                side: BorderSide(color: color.withValues(alpha: 0.4)),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w900,
                ),
                onSelected: current ? null : (_) => setState(() => _selectedStatus = status),
              );
            }).toList(),
          ),
          if (_selectedStatus == OrderModel.rejectedStatus) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Alasan Penolakan',
                hintText: 'Contoh: bahan terlalu rusak / layanan tidak tersedia',
                filled: true,
                fillColor: const Color(0xFFFFF8EC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: provider.isSubmitting ? null : () => _updateStatus(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedStatus == OrderModel.rejectedStatus
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: provider.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.notifications_active_rounded),
              label: const Text('Simpan & Kirim Notifikasi', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
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
                const SizedBox(height: 2),
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
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
      case 'menunggu kurir':
      default:
        return const Color(0xFF64748B);
    }
  }
}
