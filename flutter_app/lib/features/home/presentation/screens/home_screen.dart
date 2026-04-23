// =====================================================
// Home Screen - Ana Sayfa
// =====================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DüğünDefteri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUpcomingWeddings(),
            const SizedBox(height: 16),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildAdBanner(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildUpcomingWeddings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Yaklaşan Düğünler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('Tümü')),
              ],
            ),
            const Divider(),
            _weddingItem('Ahmet Yılmaz & Ayşe Kaya', '15 Mayıs', 'Grand Salon'),
            _weddingItem('Mehmet Demir & Fatma Şahin', '22 Mayıs', 'Krallar Salonu'),
          ],
        ),
      ),
    );
  }

  Widget _weddingItem(String names, String date, String venue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            radius: 20,
            child: const Icon(Icons.favorite, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(names, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('$date • $venue', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _statCard('💰', 'Toplam', '125.450 TL', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('👥', 'Konuk', '85', Colors.blue)),
      ],
    );
  }

  Widget _statCard(String icon, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hızlı İşlemler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _actionBtn('+ Düğün', Icons.add)),
            const SizedBox(width: 8),
            Expanded(child: _actionBtn('+ Takı', Icons.card_giftcard)),
            const SizedBox(width: 8),
            Expanded(child: _actionBtn('+ Konuk', Icons.person_add)),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(String label, IconData icon) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppTheme.primaryColor,
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('📣 Reklam Alanı', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Takvim'),
        BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Takı'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Konuk'),
        BottomNavigationBarItem(icon: Icon(Icons.undo), label: 'Geri'),
      ],
    );
  }
}