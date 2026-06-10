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

  Future<void> _updateStatus(OrderModel order) async {
    if (_selectedStatus == null || _selectedStatus == order.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih status baru terlebih dahulu.')),
      );
      return;
    }

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final success = await provider.updateStatus(id: order.id, status: _selectedStatus!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status pesanan berhasil diperbarui.'
              : provider.errorMessage ?? 'Status gagal diperbarui.',
        ),
        backgroundColor: success ? const Color(0xFF059669) : Colors.red,
      ),
    );
  }

  Future<void> _deleteOrder(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan?'),
        content: Text('Pesanan ${order.merkSepatu} akan dihapus dari database.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final success = await provider.hapusPesanan(order.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Pesanan berhasil dihapus.' : provider.errorMessage ?? 'Gagal hapus pesanan.'),
        backgroundColor: success ? const Color(0xFF059669) : Colors.red,
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

        _selectedStatus ??= order.status;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8EC),
          appBar: AppBar(
            title: const Text('Kelola Pesanan', style: TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                tooltip: 'Hapus',
                onPressed: provider.isSubmitting ? null : () => _deleteOrder(order),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildHeader(order),
              const SizedBox(height: 18),
              _buildStatusEditor(provider, order),
              const SizedBox(height: 18),
              _buildInfoCard(order),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(OrderModel order) {
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
          Text(
            order.status,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            order.merkSepatu,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '${order.layanan} • ${order.bahanSepatu}',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusEditor(OrderProvider provider, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFF8EC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: OrderModel.statusFlow
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: provider.isSubmitting
                ? null
                : (value) {
                    if (value != null) setState(() => _selectedStatus = value);
                  },
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: order.progressValue,
            minHeight: 9,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: provider.isSubmitting ? null : () => _updateStatus(order),
              icon: provider.isSubmitting
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                provider.isSubmitting ? 'Menyimpan...' : 'Simpan Status',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _row(Icons.person_rounded, 'Nama', order.customerName.isEmpty ? '-' : order.customerName),
          _row(Icons.email_rounded, 'Email', order.customerEmail.isEmpty ? '-' : order.customerEmail),
          _row(Icons.location_on_rounded, 'Alamat Pickup', order.alamatPickup),
          _row(Icons.note_alt_rounded, 'Catatan', order.catatan.isEmpty ? '-' : order.catatan),
          _row(Icons.payments_rounded, 'Estimasi Biaya', order.estimasiBiaya > 0 ? order.formattedPrice : '-'),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
