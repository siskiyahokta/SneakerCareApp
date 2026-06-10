import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class EditOrderPage extends StatefulWidget {
  final OrderModel order;

  const EditOrderPage({super.key, required this.order});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merkController;
  late final TextEditingController _alamatController;
  late final TextEditingController _catatanController;
  late String _bahanSepatu;

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
  void initState() {
    super.initState();
    _merkController = TextEditingController(text: widget.order.merkSepatu);
    _alamatController = TextEditingController(text: widget.order.alamatPickup);
    _catatanController = TextEditingController(text: widget.order.catatan);
    _bahanSepatu = _bahanOptions.contains(widget.order.bahanSepatu)
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

  Future<void> _updateOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final success = await orderProvider.updatePesanan(
      id: widget.order.id,
      merkSepatu: _merkController.text.trim(),
      bahanSepatu: _bahanSepatu,
      alamatPickup: _alamatController.text.trim(),
      catatan: _catatanController.text.trim(),
      customerEmail: authProvider.email,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Pesanan berhasil diperbarui.'
              : orderProvider.errorMessage ?? 'Pesanan gagal diperbarui.',
        ),
        backgroundColor: success ? const Color(0xFF059669) : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.order.canEdit) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Pesanan')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Pesanan tidak bisa diedit karena sudah diproses.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text('Edit Pesanan', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Layanan: ${widget.order.layanan}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _textField(
                    controller: _merkController,
                    label: 'Merk & Seri Sepatu',
                    icon: Icons.directions_run_rounded,
                    validatorText: 'Merk sepatu wajib diisi.',
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _bahanSepatu,
                    decoration: _inputDecoration('Bahan Sepatu', Icons.category_rounded),
                    items: _bahanOptions
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _bahanSepatu = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _alamatController,
                    label: 'Alamat Pickup',
                    icon: Icons.location_on_rounded,
                    validatorText: 'Alamat wajib diisi.',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: _catatanController,
                    label: 'Catatan',
                    icon: Icons.note_alt_rounded,
                    maxLines: 3,
                    isRequired: false,
                  ),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: provider.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        provider.isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: provider.isSubmitting ? null : _updateOrder,
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

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorText,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return validatorText ?? '$label wajib diisi.';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
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
}
