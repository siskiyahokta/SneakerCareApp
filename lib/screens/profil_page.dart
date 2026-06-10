import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_care_app/screens/landing_page.dart';
import 'package:sneaker_care_app/services/auth_provider.dart';
import 'package:sneaker_care_app/services/order_provider.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Provider.of<AuthProvider>(context, listen: false).logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LandingPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EC),
      appBar: AppBar(
        title: const Text(
          "Profil Akun",
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
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildProfileCard(authProvider),
              const SizedBox(height: 20),
              _buildStatsCard(orderProvider),
              const SizedBox(height: 20),
              _buildMenuCard(),
              const SizedBox(height: 20),
              _buildLogoutButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider authProvider) {
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
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.name.isEmpty
                      ? "Customer Sneakimy"
                      : authProvider.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  authProvider.email.isEmpty
                      ? "customer@sneakimycare.com"
                      : authProvider.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(OrderProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            title: "Total",
            value: provider.totalPesanan.toString(),
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            title: "Aktif",
            value: provider.pesananAktif.toString(),
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            title: "Selesai",
            value: provider.pesananSelesai.toString(),
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard() {
    final menus = [
      ProfileMenu(
        icon: Icons.verified_user_rounded,
        title: "Keamanan Sepatu",
        subtitle: "Data pesanan tersimpan dan mudah dipantau",
        color: const Color(0xFF2563EB),
      ),
      ProfileMenu(
        icon: Icons.notifications_active_rounded,
        title: "Notifikasi Progress",
        subtitle: "Digunakan untuk update status pesanan",
        color: const Color(0xFFF59E0B),
      ),
      ProfileMenu(
        icon: Icons.location_on_rounded,
        title: "Area Layanan",
        subtitle: "Polindra, Lohbener, Jatibarang, dan Indramayu",
        color: const Color(0xFF059669),
      ),
      ProfileMenu(
        icon: Icons.info_rounded,
        title: "Tentang Aplikasi",
        subtitle: "Aplikasi perawatan sneaker kolektor lokal",
        color: const Color(0xFF9333EA),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: menus.map((menu) {
          return _MenuTile(menu: menu);
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          "LOGOUT",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        onPressed: () => _logout(context),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final ProfileMenu menu;

  const _MenuTile({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: menu.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              menu.icon,
              color: menu.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.title,
                  style: const TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  menu.subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class ProfileMenu {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  ProfileMenu({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}