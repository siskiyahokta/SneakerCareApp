import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/order_detail_page.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text(
          "Pesanan Saya",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F1F1F),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.pesananList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 82,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada pesanan aktif nih.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orderProvider.pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = orderProvider.pesananList[index];

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(
                          orderId: pesanan.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 9),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F1F1F),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.directions_run_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pesanan.merkSepatu,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      color: Color(0xFF1F1F1F),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    pesanan.layanan,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _showDeleteDialog(
                                  context,
                                  orderProvider,
                                  pesanan.id,
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildStatusBadge(pesanan.status),

                        const SizedBox(height: 16),

                        _buildInfoRow(
                          icon: Icons.texture_rounded,
                          title: "Bahan",
                          value: pesanan.bahanSepatu,
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          icon: Icons.location_on_rounded,
                          title: "Pick-up",
                          value: pesanan.alamatPickup,
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                          icon: Icons.notes_rounded,
                          title: "Catatan",
                          value: pesanan.catatan,
                        ),

                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: Color(0xFFF59E0B),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Ketuk kartu untuk melihat detail dan tracking progress.",
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Color(0xFFF59E0B),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.grey,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 13.5,
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
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    OrderProvider orderProvider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text(
          "Apakah kamu yakin ingin membatalkan pesanan perawatan sepatu ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () {
              orderProvider.hapusPesanan(id);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pesanan berhasil dibatalkan."),
                  backgroundColor: Colors.red,
                ),
              );
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
}