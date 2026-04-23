// =====================================================
// Return Visit Screen - Geri Dönüş Listesi
// =====================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReturnVisitScreen extends StatelessWidget {
  const ReturnVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('↩️ Geri Dönüş'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildReturnList()),
          _buildActionBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text('Kimleri Davet Etmeliyiz?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Geçmişte düğününe gittiğiniz kişiler otomatik listelendi', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReturnList() {
    return ListView.builder(
      itemCount: _returns.length,
      itemBuilder: (context, index) {
        final item = _returns[index];
        final isSelected = item['selected'] as bool;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (v) {},
            secondary: CircleAvatar(
              backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              child: Text(item['name'][0], style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
            ),
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${item['date']} • ${item['gift']}', style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item['phone']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(item['region']!, style: TextStyle(fontSize: 10, color: AppTheme.primaryColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBar() {
    final selectedCount = _returns.where((r) => r['selected'] as bool).length;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text('$selectedCount kişi seçildi', style: const TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: selectedCount > 0 ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Davet Et 💌'),
          ),
        ],
      ),
    );
  }

  static final _returns = [
    {'name': 'Ahmet Yılmaz', 'date': '15 Haz 2023', 'gift': '1 çeyrek altın', 'phone': '0555 111 22 33', 'region': 'Diyarbakır', 'selected': true},
    {'name': 'Ayşe Kaya', 'date': '22 Tem 2024', 'gift': '5.000 TL', 'phone': '0555 444 55 66', 'region': 'Şanlıurfa', 'selected': false},
    {'name': 'Mehmet Demir', 'date': '10 Ağu 2023', 'gift': '200 \$', 'phone': '0555 777 88 99', 'region': 'Mardin', 'selected': false},
    {'name': 'Fatma Şahin', 'date': '5 Eyl 2023', 'gift': '1 tam altın', 'phone': '0555 000 11 22', 'region': 'Van', 'selected': true},
    {'name': 'Ali Yıldırım', 'date': '20 Eki 2023', 'gift': '750 TL', 'phone': '0555 222 33 44', 'region': 'Bitlis', 'selected': false},
  ];

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 4,
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