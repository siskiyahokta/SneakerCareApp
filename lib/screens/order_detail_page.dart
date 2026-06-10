import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/screens/edit_order_page.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  Future<void> _cancelOrder(BuildContext context, OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Pesanan yang dibatalkan tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.hapusPesanan(
      order.id,
      customerEmail: authProvider.email,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Pesanan berhasil dibatalkan.'
              : orderProvider.errorMessage ?? 'Pesanan gagal dibatalkan.',
        ),
        backgroundColor: success ? const Color(0xFF059669) : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final order = provider.getOrderById(orderId);

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pesanan')),
            body: const Center(child: Text('Pesanan tidak ditemukan.')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8EC),
          appBar: AppBar(
            title: const Text(
              'Detail Pesanan',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                onPressed: () => provider.fetchOrders(showLoading: true),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildHeader(order),
              const SizedBox(height: 18),
              _buildProgress(order),
              const SizedBox(height: 18),
              _buildDetailCard(order),
              const SizedBox(height: 18),
              if (order.canEdit) _buildCustomerActions(context, order),
              if (!order.canEdit)
                _buildLockedInfo('Data pesanan tidak dapat diedit karena sudah diproses oleh pemilik usaha.'),
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
          _statusBadge(order.status),
          const SizedBox(height: 14),
          Text(
            order.merkSepatu,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${order.layanan} • ${order.bahanSepatu}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (order.estimasiBiaya > 0) ...[
            const SizedBox(height: 12),
            Text(
              order.formattedPrice,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgress(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: order.progressValue,
            minHeight: 9,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 16),
          ...OrderModel.statusFlow.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final active = index <= order.progressIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                children: [
                  Icon(
                    active ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: active ? const Color(0xFF059669) : Colors.grey,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    status,
                    style: TextStyle(
                      color: active ? const Color(0xFF1F1F1F) : Colors.grey,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pesanan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _detailRow(Icons.person_rounded, 'Customer', order.customerName.isEmpty ? '-' : order.customerName),
          _detailRow(Icons.email_rounded, 'Email', order.customerEmail.isEmpty ? '-' : order.customerEmail),
          _detailRow(Icons.location_on_rounded, 'Alamat Pickup', order.alamatPickup),
          _detailRow(Icons.note_alt_rounded, 'Catatan', order.catatan.isEmpty ? '-' : order.catatan),
          _detailRow(Icons.calendar_today_rounded, 'Dibuat', order.createdAt.isEmpty ? '-' : order.createdAt),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
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
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerActions(BuildContext context, OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1F1F1F),
              side: const BorderSide(color: Color(0xFFF59E0B)),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditOrderPage(order: order)),
              );
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _cancelOrder(context, order),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedInfo(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
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
