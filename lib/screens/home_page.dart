import 'package:flutter/material.dart';
import 'package:sneaker_care_app/screens/form_pemesanan_page.dart';
import 'package:sneaker_care_app/screens/galeri_page.dart';
import 'package:sneaker_care_app/screens/pesanan_page.dart';
import 'package:sneaker_care_app/screens/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BerandaContent(),
    PesananPage(),
    GaleriPage(),
    ProfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFFF59E0B),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_rounded),
              label: "Pesanan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_rounded),
              label: "Galeri",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}

class BerandaContent extends StatelessWidget {
  const BerandaContent({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      ServiceItem(
        title: "Deep Cleaning",
        desc: "Cuci detail luar dalam",
        price: "Rp35.000",
        icon: Icons.cleaning_services_rounded,
        color: const Color(0xFF2563EB),
      ),
      ServiceItem(
        title: "Unyellowing",
        desc: "Atasi midsole menguning",
        price: "Rp50.000",
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFF59E0B),
      ),
      ServiceItem(
        title: "Repaint",
        desc: "Cat ulang bagian sepatu",
        price: "Rp75.000",
        icon: Icons.format_paint_rounded,
        color: const Color(0xFF9333EA),
      ),
      ServiceItem(
        title: "Custom Art",
        desc: "Desain custom sneaker",
        price: "Rp90.000",
        icon: Icons.brush_rounded,
        color: const Color(0xFF059669),
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildPromoCard(),

            const SizedBox(height: 26),

            _buildSectionTitle(
              title: "Layanan Favorit",
              subtitle: "Pilih perawatan sesuai kondisi sneaker kamu",
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.76,
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceCard(service: service);
              },
            ),

            const SizedBox(height: 26),

            _buildTrackingPreview(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Sneakerhead!",
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Polindra • Indramayu",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard() {
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Diskon Mahasiswa 20%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Khusus area kampus/kost. Sepatu dijemput, dicuci, lalu progress bisa dipantau.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.timeline_rounded,
              color: Color(0xFFF59E0B),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tracking Progress",
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Status pesanan bisa dipantau dari dijemput, cleaning, drying, packing, sampai selesai.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem service;

  const _ServiceCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormPemesananPage(
                layanan: service.title,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  service.icon,
                  color: service.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                service.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service.desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  service.price,
                  style: TextStyle(
                    color: service.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceItem {
  final String title;
  final String desc;
  final String price;
  final IconData icon;
  final Color color;

  ServiceItem({
    required this.title,
    required this.desc,
    required this.price,
    required this.icon,
    required this.color,
  });
}