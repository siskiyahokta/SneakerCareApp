import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class AdminOrderDetailPage extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailPage({
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

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final result = provider.pesananList
            .where((order) => order.id == orderId)
            .toList();

        if (result.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFF8EC),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              title: const Text("Detail Admin"),
            ),
            body: const Center(
              child: Text("Pesanan tidak ditemukan."),
            ),
          );
        }

        final order = result.first;
        final currentIndex = _getCurrentIndex(order.status);

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8EC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1F1F1F),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Kelola Pesanan",
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                children: [
                  _buildHeaderCard(order),
                  const SizedBox(height: 20),
                  _buildDetailCard(order),
                  const SizedBox(height: 20),
                  _buildProgressCard(currentIndex),
                  const SizedBox(height: 20),
                  _buildAdminUpdateCard(
                    context,
                    provider,
                    order,
                    currentIndex,
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
              Icons.admin_panel_settings_rounded,
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
                  "Admin Progress Control",
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
                Text(
                  order.status,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
            "Data Pesanan Customer",
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

  Widget _buildAdminUpdateCard(
    BuildContext context,
    OrderProvider provider,
    OrderModel order,
    int currentIndex,
  ) {
    final isFinished = currentIndex >= progressList.length - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Update Status Admin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFinished ? Colors.grey : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isFinished || provider.isLoading
                  ? null
                  : () async {
                      final nextStatus = progressList[currentIndex + 1];

                      final success = await provider.updateStatus(
                        order.id,
                        nextStatus,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Status berhasil diubah menjadi $nextStatus.",
                            ),
                            backgroundColor: const Color(0xFF059669),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.errorMessage ??
                                  "Gagal update status pesanan.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: provider.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isFinished
                          ? "PESANAN SUDAH SELESAI"
                          : "UPDATE KE ${progressList[currentIndex + 1].toUpperCase()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: progressList.map((status) {
              final selected = status == order.status;

              return ChoiceChip(
                label: Text(status),
                selected: selected,
                selectedColor: const Color(0xFFF59E0B),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF1F1F1F),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                onSelected: provider.isLoading
                    ? null
                    : (_) async {
                        final success = await provider.updateStatus(
                          order.id,
                          status,
                        );

                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Status diubah ke $status."),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                        }
                      },
              );
            }).toList(),
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