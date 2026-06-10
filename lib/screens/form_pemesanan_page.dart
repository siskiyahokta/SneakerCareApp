import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class FormPemesananPage extends StatefulWidget {
  final String? layanan;
  final String? selectedService;
  final int? estimasiBiaya;

  const FormPemesananPage({
    super.key,
    this.layanan,
    this.selectedService,
    this.estimasiBiaya,
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
  String _layanan = 'Deep Cleaning';
  int _estimasiBiaya = 35000;
  File? _selectedImage;

  final List<String> _bahanOptions = const [
    'Canvas',
    'Leather',
    'Suede',
    'Knit',
    'Mesh',
    'Synthetic',
  ];

  final Map<String, int> _servicePrice = const {
    'Deep Cleaning': 35000,
    'Unyellowing': 50000,
    'Repaint': 75000,
    'Custom Art': 90000,
  };

  @override
  void initState() {
    super.initState();
    final initialService = widget.layanan ?? widget.selectedService ?? 'Deep Cleaning';
    _layanan = initialService;
    _estimasiBiaya = widget.estimasiBiaya ?? _servicePrice[initialService] ?? 35000;
  }

  @override
  void dispose() {
    _merkController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 78,
      maxWidth: 1280,
    );
    if (picked == null) return;
    setState(() => _selectedImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text('Buat Pesanan'),
        backgroundColor: const Color(0xFFFFF8EC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 16),
              _buildServiceSelector(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 16),
              _buildPhotoPicker(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: orderProvider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1F1F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: Text(orderProvider.isLoading ? 'Mengirim Pesanan...' : 'Kirim Pesanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF3B2A12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pesan Perawatan Sneaker', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Upload foto sepatu agar vendor bisa cek kondisi awal.', style: TextStyle(color: Colors.white.withValues(alpha: 0.70))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Layanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _servicePrice.entries.map((entry) {
              final selected = _layanan == entry.key;
              return ChoiceChip(
                selected: selected,
                label: Text('${entry.key} • ${_currency(entry.value)}'),
                selectedColor: const Color(0xFF1F1F1F),
                backgroundColor: const Color(0xFFFFFBF4),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF374151),
                  fontWeight: FontWeight.w800,
                ),
                side: BorderSide(color: selected ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB)),
                onSelected: (_) {
                  setState(() {
                    _layanan = entry.key;
                    _estimasiBiaya = entry.value;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          TextFormField(
            controller: _merkController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('Merk / Nama Sepatu', Icons.checkroom_rounded),
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return 'Merk sepatu wajib diisi minimal 2 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _bahanSepatu,
            decoration: _inputDecoration('Bahan Sepatu', Icons.texture_rounded),
            items: _bahanOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) => setState(() => _bahanSepatu = value ?? 'Canvas'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _alamatController,
            maxLines: 3,
            decoration: _inputDecoration('Alamat Pickup', Icons.location_on_rounded),
            validator: (value) {
              if (value == null || value.trim().length < 8) {
                return 'Alamat pickup wajib diisi dengan jelas';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _catatanController,
            maxLines: 3,
            decoration: _inputDecoration('Catatan Tambahan (opsional)', Icons.note_alt_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Foto Sepatu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Tambahkan foto supaya pemilik usaha bisa melihat kondisi sepatu sebelum diproses.', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _selectedImage == null
                ? Container(
                    height: 185,
                    width: double.infinity,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(child: Icon(Icons.add_photo_alternate_rounded, size: 54, color: Color(0xFF9CA3AF))),
                  )
                : Image.file(_selectedImage!, height: 220, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Kamera'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('Galeri'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload foto sepatu dulu agar pesanan lebih lengkap.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<OrderProvider>(context, listen: false);

    final success = await provider.tambahPesanan(
      layanan: _layanan,
      merkSepatu: _merkController.text.trim(),
      bahanSepatu: _bahanSepatu,
      alamatPickup: _alamatController.text.trim(),
      catatan: _catatanController.text.trim(),
      customerName: auth.name,
      customerEmail: auth.email,
      estimasiBiaya: _estimasiBiaya,
      shoePhotoFile: _selectedImage,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Pesanan berhasil dikirim.' : provider.errorMessage ?? 'Gagal membuat pesanan.'),
        backgroundColor: success ? const Color(0xFF059669) : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFFFFBF4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.055), blurRadius: 16, offset: const Offset(0, 8))],
    );
  }

  String _currency(int value) {
    final text = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $text';
  }
}
