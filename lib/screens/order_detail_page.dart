import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/services/api_service.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final order = provider.orders.firstWhere(
      (item) => item.id == widget.order.id,
      orElse: () => widget.order,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFFFF8EC),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchOrders,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHeader(order),
            const SizedBox(height: 16),
            _buildPhotoCard(order),
            const SizedBox(height: 16),
            _buildInfoCard(order),
            const SizedBox(height: 16),
            _buildProgressCard(order),
            const SizedBox(height: 16),
            _buildReviewSection(order, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.local_laundry_service_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.layanan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.70)),
                    ),
                  ],
                ),
              ),
              _statusChip(order.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Estimasi biaya',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.70)),
          ),
          const SizedBox(height: 4),
          Text(
            _currency(order.estimasiBiaya),
            style: const TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(OrderModel order) {
    final image = ApiService.imageUrl(order.shoePhoto);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Sepatu',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: image.isEmpty
                ? Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Text('Belum ada foto sepatu'),
                    ),
                  )
                : Image.network(
                    image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(child: Text('Foto tidak bisa dimuat')),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pesanan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _infoRow('Merk Sepatu', order.merkSepatu),
          _infoRow('Bahan', order.bahanSepatu),
          _infoRow('Alamat Pickup', order.alamatPickup),
          _infoRow('Catatan', order.catatan.isEmpty ? '-' : order.catatan),
          if (order.isRejected && order.rejectionReason.isNotEmpty)
            _infoRow('Alasan Ditolak', order.rejectionReason),
        ],
      ),
    );
  }

  Widget _buildProgressCard(OrderModel order) {
    const steps = [
      'Menunggu Kurir',
      'Dijemput Kurir',
      'Cleaning',
      'Drying',
      'Packing',
      'Selesai',
    ];

    final currentIndex = steps.indexWhere(
      (step) => step.toLowerCase() == order.status.toLowerCase(),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Progress',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (order.isRejected)
            _timelineItem('Ditolak', true, true)
          else
            ...List.generate(steps.length, (index) {
              final done = currentIndex >= index;
              return _timelineItem(steps[index], done, index == steps.length - 1);
            }),
        ],
      ),
    );
  }

  Widget _timelineItem(String title, bool done, bool last) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFF059669) : const Color(0xFFE5E7EB),
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.circle,
                size: done ? 16 : 8,
                color: done ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
            if (!last)
              Container(
                height: 32,
                width: 2,
                color: done ? const Color(0xFF059669) : const Color(0xFFE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: done ? FontWeight.w800 : FontWeight.w500,
              color: done ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(OrderModel order, OrderProvider provider) {
    if (!order.isFinished) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: const Text(
          'Rating dan ulasan akan aktif setelah pesanan selesai.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    if (order.hasRating) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ulasan Kamu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, color: i < order.rating ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB)))),
            const SizedBox(height: 10),
            Text(order.review.isEmpty ? 'Tidak ada komentar.' : order.review),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Beri Rating Layanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = value),
                icon: Icon(
                  Icons.star_rounded,
                  size: 34,
                  color: value <= _rating ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tulis ulasan singkat tentang layanan Sneakimy Care...',
              filled: true,
              fillColor: const Color(0xFFFFFBF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : () => _submitReview(order, provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.send_rounded),
              label: Text(provider.isLoading ? 'Mengirim...' : 'Kirim Rating'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview(OrderModel order, OrderProvider provider) async {
    final review = _reviewController.text.trim();
    final success = await provider.submitReview(
      id: order.id,
      rating: _rating,
      review: review,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Rating berhasil dikirim.' : provider.errorMessage ?? 'Gagal mengirim rating.'),
        backgroundColor: success ? const Color(0xFF059669) : Colors.red,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'selesai') return const Color(0xFF059669);
    if (s == 'ditolak') return const Color(0xFFDC2626);
    if (s == 'menunggu kurir') return const Color(0xFF6B7280);
    return const Color(0xFFF59E0B);
  }

  String _currency(int value) {
    final text = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $text';
  }
}
