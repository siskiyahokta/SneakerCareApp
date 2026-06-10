import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/pesanan_page.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/notification_service.dart';
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
  final ImagePicker _picker = ImagePicker();

  String _bahanSepatu = 'Canvas';
  File? _selectedImage;

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showImageSourceSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Foto Sepatu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFFF59E0B)),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFF59E0B)),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
      shoePhotoPath: _selectedImage?.path,
    );

    if (!mounted) return;

    if (success) {
      await NotificationService.showOrderCreatedNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat. Pemilik usaha akan mengonfirmasi.'),
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
        backgroundColor: const Color(0xFFFFF8EC),
        title: const Text(
          'Form Pemesanan',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _buildServiceHeader(),
                const SizedBox(height: 18),
                _buildImagePickerCard(),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _merkController,
                  label: 'Merk & Seri Sepatu',
                  hint: 'Contoh: Adidas Samba / Nike AF1',
                  icon: Icons.directions_run_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Merk sepatu wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildMaterialDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _alamatController,
                  label: 'Alamat Pickup',
                  hint: 'Tulis alamat lengkap penjemputan',
                  icon: Icons.location_on_rounded,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alamat pickup wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _catatanController,
                  label: 'Catatan Tambahan',
                  hint: 'Contoh: noda membandel, warna mudah luntur, dll',
                  icon: Icons.edit_note_rounded,
                  maxLines: 4,
                ),
                const SizedBox(height: 18),
                _buildInfoBox(),
                const SizedBox(height: 22),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: orderProvider.isSubmitting ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: orderProvider.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      orderProvider.isSubmitting ? 'Mengirim Pesanan...' : 'Kirim Pesanan',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
              ],
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
          colors: [Color(0xFF1F1F1F), Color(0xFF8A5A00), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Layanan Dipilih', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            widget.layanan,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload foto supaya pemilik usaha bisa mengecek kondisi sepatu sebelum dijemput.',
            style: TextStyle(color: Colors.white70, height: 1.4, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _showImageSourceSheet,
      child: Container(
        height: _selectedImage == null ? 150 : 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.45), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: Color(0xFFF59E0B)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tambah Foto Sepatu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 5),
                  const Text('Opsional, tapi disarankan untuk validasi kondisi', style: TextStyle(color: Colors.grey)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Foto sepatu siap dikirim',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF5F574A)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildMaterialDropdown() {
    return DropdownButtonFormField<String>(
      value: _bahanSepatu,
      items: _bahanOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _bahanSepatu = value);
      },
      decoration: InputDecoration(
        labelText: 'Bahan Sepatu',
        prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF5F574A)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD78A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: Color(0xFFF59E0B)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pesanan masih bisa diedit atau dibatalkan selama status masih Menunggu Kurir.',
              style: TextStyle(fontWeight: FontWeight.w800, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
