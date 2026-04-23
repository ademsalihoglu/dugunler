// =====================================================
// Calendar Screen - Düğün Takvimi
// =====================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Takvim')),
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildCalendarGrid(),
          const Divider(),
          Expanded(child: _buildDayEvents()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMonthSelector() {
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1))),
          Text('${months[_selectedMonth.month - 1]} ${_selectedMonth.year}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1))),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
      itemCount: 35,
      itemBuilder: (context, index) {
        final day = index - ((_selectedMonth.weekday - 1) % 7) + 1;
        if (day < 1 || day > DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day) {
          return const SizedBox();
        }
        final hasEvent = [15, 22].contains(day); // Mock events
        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: hasEvent ? AppTheme.primaryColor : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text('$day', style: TextStyle(color: hasEvent ? Colors.white : null, fontWeight: hasEvent ? FontWeight.bold : null)),
          ),
        );
      },
    );
  }

  Widget _buildDayEvents() {
    return ListView(
      children: const [
        ListTile(
          leading: CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Icon(Icons.favorite, color: Colors.white, size: 20)),
          title: Text('Ahmet Yılmaz & Ayşe Kaya'),
          subtitle: Text('15 Mayıs 2026 • 14:00 • Grand Salon'),
          trailing: Icon(Icons.chevron_right),
        ),
        ListTile(
          leading: CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.favorite, color: Colors.white, size: 20)),
          title: Text('Mehmet Demir & Fatma Şahin'),
          subtitle: Text('22 Mayıs 2026 • 15:00 • Krallar Salonu'),
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
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