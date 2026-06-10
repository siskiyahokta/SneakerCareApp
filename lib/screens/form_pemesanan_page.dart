import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/pesanan_page.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class FormPemesananPage extends StatefulWidget {
  final String layanan;

  const FormPemesananPage({
    super.key,
    required this.layanan,
  });

  @override
  State<FormPemesananPage> createState() => _FormPemesananPageState();
}

class _FormPemesananPageState extends State<FormPemesananPage> {
  final _formKey = GlobalKey<FormState>();
  final _merkController = TextEditingController();
  final _alamatController = TextEditingController();
  final _catatanController = TextEditingController();

  String _bahanSepatu = 'Canvas';

  final List<String> _bahanOptions = const [
    'Canvas',
    'Leather',
    'Suede',
    'Knit/Flyknit',
    'Mesh',
    'Nubuck',
    'Campuran',
  ];

  @override
  void dispose() {
    _merkController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final success = await orderProvider.tambahPesanan(
      layanan: widget.layanan,
      merkSepatu: _merkController.text.trim(),
      bahanSepatu: _bahanSepatu,
      alamatPickup: _alamatController.text.trim(),
      catatan: _catatanController.text.trim(),
      customerName: authProvider.name.isEmpty ? 'Customer Sneakimy' : authProvider.name,
      customerEmail: authProvider.email.isEmpty ? 'customer@sneakimycare.com' : authProvider.email,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat. Kurir akan segera menjemput.'),
          backgroundColor: Color(0xFF059669),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PesananPage()),
        (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'Pesanan gagal dibuat.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text(
          'Form Pemesanan',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceHeader(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _merkController,
                    label: 'Merk & Seri Sepatu',
                    hint: 'Contoh: Nike Air Jordan 1',
                    icon: Icons.directions_run_rounded,
                    validatorText: 'Merk sepatu wajib diisi.',
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _alamatController,
                    label: 'Alamat Pickup',
                    hint: 'Contoh: Kos dekat Polindra / Jatibarang',
                    icon: Icons.location_on_rounded,
                    validatorText: 'Alamat pickup wajib diisi.',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _catatanController,
                    label: 'Catatan Tambahan',
                    hint: 'Contoh: noda membandel di bagian midsole',
                    icon: Icons.note_alt_rounded,
                    maxLines: 3,
                    isRequired: false,
                  ),
                  const SizedBox(height: 22),
                  _buildInfoBox(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: orderProvider.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        orderProvider.isSubmitting ? 'Memproses...' : 'Buat Pesanan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: orderProvider.isSubmitting ? null : _submitOrder,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1F1F), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 38),
          const SizedBox(height: 14),
          const Text(
            'Layanan Dipilih',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            widget.layanan,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _bahanSepatu,
      decoration: _inputDecoration(
        label: 'Bahan Sepatu',
        hint: 'Pilih bahan sepatu',
        icon: Icons.category_rounded,
      ),
      items: _bahanOptions
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _bahanSepatu = value);
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? validatorText,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return validatorText ?? '$label wajib diisi.';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: Color(0xFFF59E0B)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pesanan masih bisa diedit atau dibatalkan selama status masih Menunggu Kurir.',
              style: TextStyle(
                color: Color(0xFF444444),
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
