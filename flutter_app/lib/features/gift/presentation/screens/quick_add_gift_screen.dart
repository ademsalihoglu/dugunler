// =====================================================
// Quick Add Gift Screen - Hızlı Takı Giriş Ekranı
// Büyük butonlar - Yaşlı kullanıcılar için kolay kullanım
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/sync_repository.dart';
import '../domain/gift_service.dart';

class QuickAddGiftScreen extends ConsumerStatefulWidget {
  final String weddingId;
  final String? guestId;
  final String? guestName;

  const QuickAddGiftScreen({
    super.key,
    required this.weddingId,
    this.guestId,
    this.guestName,
  });

  @override
  ConsumerState<QuickAddGiftScreen> createState() => _QuickAddGiftScreenState();
}

class _QuickAddGiftScreenState extends ConsumerState<QuickAddGiftScreen> {
  String? _selectedGiftTypeId;
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final giftTypesAsync = ref.watch(giftTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Takı Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: giftTypesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (giftTypes) => _buildContent(giftTypes),
        ),
      ),
    );
  }

  Widget _buildContent(List<GiftType> giftTypes) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Konuk Bilgisi (varsa)
          if (widget.guestName != null) ...[
            Card(
              color: AppTheme.secondaryColor.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 32, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.guestName!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Takı Tipi Seçimi
          const Text(
            'Ne takıldı?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Büyük Grid Butonlar (3 kolon)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: giftTypes.length,
            itemBuilder: (context, index) {
              final type = giftTypes[index];
              final isSelected = _selectedGiftTypeId == type.id;

              return _GiftTypeButton(
                giftType: type,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedGiftTypeId = type.id),
              );
            },
          ),

          const SizedBox(height: 32),

          // Miktar Girişi
          const Text(
            'Miktar?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24),
            decoration: InputDecoration(
              hintText: _selectedGiftTypeId?.contains('GOLD') 
                  ? 'Adet girin' 
                  : 'Miktar girin',
              suffixIcon: _selectedGiftTypeId != null
                  ? _buildUnitWidget(giftTypes)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // TL Karşılığı Göster
          if (_selectedGiftTypeId != null && _quantityController.text.isNotEmpty)
            _buildTLPreview(giftTypes),

          const SizedBox(height: 24),

          // Not (opsiyonel)
          const Text(
            'Not (opsiyonel)',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              hintText: 'Örn: Düğün hayırlı olsun',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Kaydet Butonu (Büyük)
          SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: _canSave() ? _saveGift : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'KAYDET',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Başarı mesajı
          Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(quickAddGiftProvider);
              if (state.isSuccess) {
                return Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Takı kaydedildi!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            ref.read(quickAddGiftProvider.notifier).reset();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnitWidget(List<GiftType> giftTypes) {
    final selected = giftTypes.firstWhere(
      (t) => t.id == _selectedGiftTypeId,
      orElse: () => giftTypes.first,
    );
    
    String unitText = '';
    switch (selected.unit) {
      case 'adet':
        unitText = 'adet';
        break;
      case 'gram':
        unitText = 'gram';
        break;
      case 'tl':
        unitText = 'TL';
        break;
      case 'dolar':
        unitText = '\$';
        break;
      case 'euro':
        unitText = '€';
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Text(
          unitText,
          style: const TextStyle(fontSize: 18, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildTLPreview(List<GiftType> giftTypes) {
    final selected = giftTypes.firstWhere(
      (t) => t.id == _selectedGiftTypeId,
      orElse: () => giftTypes.first,
    );
    
    final qty = double.tryParse(_quantityController.text) ?? 0;
    // Basit hesaplama (gerçek API'den alınacak)
    double rate = 1.0;
    if (selected.code.contains('GOLD')) rate = 2700;
    if (selected.code == 'USD') rate = 32.5;
    if (selected.code == 'EUR') rate = 35;
    
    double totalTry = qty * rate;
    if (selected.code == 'QUARTER_GOLD') totalTry = qty * rate * 0.75;
    
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tahmini Değer:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '${totalTry.toStringAsFixed(0)} TL',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSave() {
    return _selectedGiftTypeId != null &&
        _quantityController.text.isNotEmpty &&
        !_isLoading;
  }

  Future<void> _saveGift() async {
    if (!_canSave()) return;

    setState(() => _isLoading = true);

    try {
      final qty = double.parse(_quantityController.text);
      final note = _noteController.text.isEmpty ? null : _noteController.text;

      await ref.read(quickAddGiftProvider.notifier).addGift(
        weddingId: widget.weddingId,
        guestId: widget.guestId,
        giftTypeId: _selectedGiftTypeId!,
        quantity: qty,
        note: note,
      );

      // Formu temizle
      _quantityController.clear();
      _noteController.clear();
      setState(() {
        _selectedGiftTypeId = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}

// =====================================================
// Gift Type Button Widget
// Büyük, kolay tıklanabilir buton
// =====================================================

class _GiftTypeButton extends StatelessWidget {
  final GiftType giftType;
  final bool isSelected;
  final VoidCallback onTap;

  const _GiftTypeButton({
    required this.giftType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.primaryColor
          : AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textTertiary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İkon
              Text(
                giftType.icon ?? '💰',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              // İsim
              Text(
                giftType.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// Gift List Summary Widget
// =====================================================

class GiftListSummary extends StatelessWidget {
  final List<Gift> gifts;
  final double totalTry;

  const GiftListSummary({
    super.key,
    required this.gifts,
    required this.totalTry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Toplam:',
                  style: TextStyle(fontSize: 18),
                ),
                const Spacer(),
                Text(
                  '${totalTry.toStringAsFixed(0)} TL',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${gifts.length} konuk takı verdi',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}