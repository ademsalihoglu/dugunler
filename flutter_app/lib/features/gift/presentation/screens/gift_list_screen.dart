// =====================================================
// Gift List Screen - Takı Listesi
// =====================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GiftListScreen extends StatelessWidget {
  const GiftListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Takılar'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildTotalCard(),
          Expanded(child: _buildGiftList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Toplam', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('125.450 TL', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const Text('(Güncel: 145.200 TL)', style: TextStyle(color: Colors.green)),
            const SizedBox(height: 8),
            Text('${_gifts.length} konuk takı verdi', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftList() {
    return ListView.builder(
      itemCount: _gifts.length,
      itemBuilder: (context, index) {
        final gift = _gifts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppTheme.secondaryColor.withOpacity(0.2), radius: 24, child: Text(gift['icon'], style: const TextStyle(fontSize: 24))),
            title: Text(gift['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${gift['amount']} • ${gift['date']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${gift['try']} TL', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (gift['note'] != null) Text(gift['note']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  static final _gifts = [
    {'name': 'Ahmet Yılmaz', 'icon': '💍', 'amount': '1 çeyrek altın', 'date': '15:30', 'try': '12.000', 'note': 'Düğün hayırlı olsun'},
    {'name': 'Ayşe Kaya', 'icon': '💵', 'amount': '500 TL', 'date': '14:45', 'try': '500', 'note': null},
    {'name': 'Mehmet Demir', 'icon': '💰', 'amount': '1 tam altın', 'date': '16:00', 'try': '48.000', 'note': 'Emekli oldu hayırlıssını'},
    {'name': 'Fatma Şahin', 'icon': '💶', 'amount': '100 Euro', 'date': '15:00', 'try': '3.500', 'note': null},
    {'name': 'Ali Yıldırım', 'icon': '₺', 'amount': '1.000 TL', 'date': '14:00', 'try': '1.000', 'note': 'Kaynanam'},
  ];

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
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