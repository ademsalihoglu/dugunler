// =====================================================
// Guest List Screen - Davetli Listesi
// =====================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GuestListScreen extends StatelessWidget {
  const GuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Davetli Listesi'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildStats(),
          Expanded(child: _buildGuestList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('85', 'Toplam'),
          _statItem('45', 'Davetli'),
          _statItem('25', 'Onay'),
          _statItem('15', 'Bekleyen'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildGuestList() {
    return ListView(
      children: [
        _sectionHeader('Katılacak', Colors.green),
        _guestTile('Ahmet Yılmaz', 'Akademisyen', '+3', true),
        _guestTile('Ayşe Kaya', 'Akrabam', '+2', true),
        _guestTile('Mehmet Demir', 'İş arkadaşı', '+1', true),
        _sectionHeader('Bekleyen', Colors.orange),
        _guestTile('Fatma Şahin', 'Teyze', '+4', null),
        _guestTile('Ali Yıldırım', 'Amca', '+2', null),
        _sectionHeader('Katılmayacak', Colors.red),
        _guestTile('Veli Kaya', 'Komşu', '0', false),
      ],
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _guestTile(String name, String relation, String party, bool? confirmed) {
    IconData icon;
    Color color;
    if (confirmed == true) {
      icon = Icons.check_circle; color = Colors.green;
    } else if (confirmed == false) {
      icon = Icons.cancel; color = Colors.red;
    } else {
      icon = Icons.hourglass_empty; color = Colors.orange;
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text(name[0])),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(relation),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+$party', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
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