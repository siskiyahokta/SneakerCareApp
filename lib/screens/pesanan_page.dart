import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Saya", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  Icon(Icons.layers_clear, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada pesanan aktif nih.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderProvider.pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = orderProvider.pesananList[index];

              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF0D47A1),
                    child: Icon(Icons.directions_run, color: Colors.white),
                  ),
                  title: Text(
                    pesanan.merkSepatu,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Layanan: ${pesanan.layanan}"),
                      const SizedBox(height: 8),
                      // Badge Status Sepatu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pesanan.status,
                          style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                 
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Batalkan Pesanan?"),
                          content: const Text("Apakah kamu yakin ingin membatalkan pesanan perawatan sepatu ini?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tidak"),
                            ),
                            TextButton(
                              onPressed: () {
                    
                                orderProvider.hapusPesanan(pesanan.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Pesanan berhasil dibatalkan."), backgroundColor: Colors.red),
                                );
                              },
                              child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}