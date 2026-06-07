import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class EditOrderPage extends StatefulWidget {
  final OrderModel order;

  const EditOrderPage({
    super.key,
    required this.order,
  });

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _merkController;
  late TextEditingController _alamatController;
  late TextEditingController _catatanController;

  late String _selectedBahan;

  final List<String> _bahanSepatu = [
    'Canvas',
    'Leather',
    'Suede',
    'Nubuck',
    'Knit',
    'Mesh',
    'Synthetic',
  ];

  @override
  void initState() {
    super.initState();

    _merkController = TextEditingController(text: widget.order.merkSepatu);
    _alamatController = TextEditingController(text: widget.order.alamatPickup);
    _catatanController = TextEditingController(
      text: widget.order.catatan == '-' ? '' : widget.order.catatan,
    );

    _selectedBahan = _bahanSepatu.contains(widget.order.bahanSepatu)
        ? widget.order.bahanSepatu
        : 'Canvas';
  }

  @override
  void dispose() {
    _merkController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _updatePesanan() async {
    if (!_formKey.currentState!.validate()) return;

    final orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    final success = await orderProvider.updatePesanan(
      id: widget.order.id,
      merkSepatu: _merkController.text.trim(),
      bahanSepatu: _selectedBahan,
      alamatPickup: _alamatController.text.trim(),
      catatan: _catatanController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data pesanan berhasil diperbarui di database."),
          backgroundColor: Color(0xFF059669),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderProvider.errorMessage ??
                "Gagal memperbarui pesanan. Cek koneksi API.",
          ),
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
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit Pesanan",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeaderCard(),

                const SizedBox(height: 22),

                _buildTextField(
                  controller: _merkController,
                  label: "Merk & Seri Sepatu",
                  hint: "Contoh: New Balance 550 / Adidas Samba",
                  icon: Icons.directions_run_rounded,
                  validatorText: "Merk dan seri sepatu wajib diisi",
                ),

                const SizedBox(height: 16),

                _buildDropdownBahan(),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _alamatController,
                  label: "Alamat Pick-up",
                  hint: "Contoh: Kost dekat Polindra / Jatibarang",
                  icon: Icons.location_on_rounded,
                  maxLines: 3,
                  validatorText: "Alamat pick-up wajib diisi",
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _catatanController,
                  label: "Catatan Tambahan",
                  hint: "Contoh: Bagian sole kuning, hati-hati bahan suede",
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  isRequired: false,
                ),

                const SizedBox(height: 26),

                Consumer<OrderProvider>(
                  builder: (context, orderProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed:
                            orderProvider.isLoading ? null : _updatePesanan,
                        child: orderProvider.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "SIMPAN PERUBAHAN",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                const Text(
                  "Perubahan data pesanan akan dikirim ke backend dan diperbarui di database MySQL.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update Data Pesanan",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.order.layanan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownBahan() {
    return DropdownButtonFormField<String>(
      value: _selectedBahan,
      decoration: _inputDecoration(
        label: "Bahan Sepatu",
        hint: "Pilih bahan sepatu",
        icon: Icons.texture_rounded,
      ),
      items: _bahanSepatu.map((bahan) {
        return DropdownMenuItem<String>(
          value: bahan,
          child: Text(bahan),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedBahan = value;
          });
        }
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
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
        maxLines: maxLines,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return validatorText ?? "Field ini wajib diisi";
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          bottom: maxLines > 1 ? 44 : 0,
        ),
        child: Icon(icon),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFF59E0B),
          width: 2,
        ),
      ),
    );
  }
}