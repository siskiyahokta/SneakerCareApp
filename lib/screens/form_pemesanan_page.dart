import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class FormPemesananPage extends StatefulWidget {
  final String layanan; // Menerima jenis layanan yang dipilih dari beranda

  const FormPemesananPage({super.key, required this.layanan});

  @override
  State<FormPemesananPage> createState() => _FormPemesananPageState();
}

class _FormPemesananPageState extends State<FormPemesananPage> {
  final _merkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _merkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Pemesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1), // Biru Polindra
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Layanan yang dipilih
              Text(
                "Layanan yang dipilih: ${widget.layanan}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 20),

              // Input Merk Sepatu
              TextFormField(
                controller: _merkController,
                decoration: InputDecoration(
                  labelText: "Merk & Seri Sepatu",
                  hintText: "Contoh: Nike Air Jordan 1 / Compass Gazelle",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.abc),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Merk sepatu tidak boleh kosong!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Tombol Pesan Sekarang (FUNGSI CREATE)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00), // Orange Sporty
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // PANGGIL FUNGSI CREATE DARI PROVIDER
                      Provider.of<OrderProvider>(context, listen: false).tambahPesanan(
                        widget.layanan, 
                        _merkController.text,
                      );

                      // Tampilkan SnackBer sukses
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pesanan berhasil dibuat! Kurir akan segera menjemput."),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Kembali ke halaman sebelumnya
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "PESAN SEKARANG",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}