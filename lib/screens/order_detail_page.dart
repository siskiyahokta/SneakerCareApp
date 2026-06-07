import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/edit_order_page.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({
    super.key,
    required this.orderId,
  });

  static const List<String> progressList = [
    'Menunggu Kurir',
    'Dijemput Kurir',
    'Cleaning',
    'Drying',
    'Packing',
    'Selesai',
  ];

  int _getCurrentIndex(String status) {
    final index = progressList.indexOf(status);
    return index == -1 ? 0 : index;
  }

  bool _canCustomerEdit(String status) {
    return status == 'Menunggu Kurir';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final result = orderProvider.pesananList
            .where((order) => order.id == orderId)
            .toList();

        if (result.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFF8EC),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              title: const Text("Detail Pesanan"),
            ),
            body: const Center(
              child: Text(
                "Pesanan tidak ditemukan.",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final order = result.first;
        final currentIndex = _getCurrentIndex(order.status);
        final canEdit = _canCustomerEdit(order.status);

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8EC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1F1F1F),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Detail Pesanan",
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(order),
                  const SizedBox(height: 20),
                  _buildDetailCard(order),
                  const SizedBox(height: 20),
                  _buildProgressCard(currentIndex),
                  const SizedBox(height: 20),
                  _buildCustomerActionCard(
                    context,
                    orderProvider,
                    order,
                    canEdit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(OrderModel order) {
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tracking Pesanan",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.merkSepatu,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Pesanan",
            style: TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.cleaning_services_rounded,
            title: "Layanan",
            value: order.layanan,
          ),
          _buildInfoRow(
            icon: Icons.texture_rounded,
            title: "Bahan Sepatu",
            value: order.bahanSepatu,
          ),
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            title: "Alamat Pick-up",
            value: order.alamatPickup,
          ),
          _buildInfoRow(
            icon: Icons.notes_rounded,
            title: "Catatan",
            value: order.catatan,
          ),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            title: "Tanggal Pesan",
            value: order.createdAt,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int currentIndex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Pengerjaan",
            style: TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Customer hanya dapat memantau progress. Perubahan status dilakukan oleh admin.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(progressList.length, (index) {
              final isDone = index < currentIndex;
              final isActive = index == currentIndex;

              return _buildProgressItem(
                title: progressList[index],
                isDone: isDone,
                isActive: isActive,
                isLast: index == progressList.length - 1,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerActionCard(
    BuildContext context,
    OrderProvider provider,
    OrderModel order,
    bool canEdit,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Aksi Customer",
            style: TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canEdit
                ? "Pesanan masih menunggu kurir, jadi data masih bisa diedit atau dibatalkan."
                : "Pesanan sudah diproses, data tidak bisa diedit agar alur pengerjaan tetap aman.",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    canEdit ? const Color(0xFFF59E0B) : Colors.grey,
                side: BorderSide(
                  color: canEdit ? const Color(0xFFF59E0B) : Colors.grey,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.edit_rounded),
              label: const Text(
                "EDIT DATA PESANAN",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              onPressed: canEdit
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditOrderPage(order: order),
                        ),
                      );
                    }
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: canEdit ? Colors.red : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text(
                "BATALKAN PESANAN",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              onPressed: canEdit
                  ? () {
                      _showDeleteDialog(context, provider, order.id);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    OrderProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text(
          "Pesanan hanya bisa dibatalkan saat status masih Menunggu Kurir.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final success = await provider.hapusPesanan(id);

              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pesanan berhasil dibatalkan."),
                    backgroundColor: Colors.red,
                  ),
                );

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ?? "Gagal membatalkan pesanan.",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String title,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    final Color activeColor =
        isDone || isActive ? const Color(0xFFF59E0B) : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone
                    ? Icons.check_rounded
                    : isActive
                        ? Icons.local_laundry_service_rounded
                        : Icons.circle_outlined,
                color: isDone || isActive ? Colors.white : Colors.grey,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 34,
                color: activeColor.withValues(alpha: 0.35),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              style: TextStyle(
                color:
                    isDone || isActive ? const Color(0xFF1F1F1F) : Colors.grey,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}