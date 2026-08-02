import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app_providers.dart';
import '../../../services/locale_provider.dart';
import '../../../theme/tokens.dart';

/// Handing the day's cash to the depot.
///
/// The driver states a figure; somebody else counts it. This screen never shows a "handed over"
/// confirmation, because nothing has been handed over until a second person says so — telling a
/// driver his money is in would be the one lie that makes the whole chain worthless.
class CashHandoverScreen extends ConsumerStatefulWidget {
  const CashHandoverScreen({super.key});

  static const routeName = '/cash/handover';

  @override
  ConsumerState<CashHandoverScreen> createState() => _CashHandoverScreenState();
}

class _CashHandoverScreenState extends ConsumerState<CashHandoverScreen> {
  final _amountCtrl = TextEditingController();

  double? _outstanding;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final amount = await ref.read(deliveryRepositoryProvider).cashOutstanding();
      if (!mounted) return;
      setState(() {
        _outstanding = amount;
        // Pre-filled with what the platform believes he holds. It is a starting point, not a claim:
        // he can change it, and the gap between this figure and what the depot counts is the only
        // thing anyone will look at afterwards.
        _amountCtrl.text = _format(amount);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'network'; });
    }
  }

  static String _format(double v) => v.toStringAsFixed(3).replaceAll('.', ',');

  double get _declared {
    final raw = _amountCtrl.text.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  Future<void> _submit(String locale) async {
    setState(() => _submitting = true);
    try {
      await ref.read(deliveryRepositoryProvider).declareCash(_declared);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(locale == 'ar'
            ? 'تم التصريح. في انتظار العدّ في المستودع.'
            : 'Déclaré. En attente du comptage au dépôt.'),
      ));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTokens.dangerRed,
        content: Text(locale == 'ar'
            ? 'تعذّر التصريح. حاول مرة أخرى.'
            : 'Déclaration impossible. Réessayez.'),
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final ar = locale == 'ar';
    final nothingToHandOver = (_outstanding ?? 0) <= 0;

    return Scaffold(
      appBar: AppBar(title: Text(ar ? 'تسليم الصندوق' : 'Remise de caisse')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _Retry(onRetry: _load, ar: ar)
              : ListView(
                  padding: const EdgeInsets.all(AppTokens.space20),
                  children: [
                    // What the platform knows he took — the figure he is measured against.
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTokens.infoBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                            ),
                            child: const Icon(LucideIcons.wallet, size: 20, color: AppTokens.infoBlue),
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ar ? 'ما حصّلته' : 'Encaissé par vous',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: AppTokens.fwMedium,
                                      color: cs.onSurfaceVariant),
                                ),
                                const SizedBox(height: AppTokens.space2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      _format(_outstanding ?? 0),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: AppTokens.fwBold,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                    const SizedBox(width: AppTokens.space6),
                                    Text('TND',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: AppTokens.fwMedium,
                                            color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (nothingToHandOver) ...[
                      const SizedBox(height: AppTokens.space24),
                      Text(
                        ar
                            ? 'لا يوجد مبلغ للتسليم.'
                            : 'Rien à remettre pour le moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                      ),
                    ] else ...[
                      const SizedBox(height: AppTokens.space24),
                      Text(
                        ar ? 'المبلغ الذي تسلّمه' : 'Montant que vous remettez',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: AppTokens.fwMedium,
                            color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppTokens.space8),
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: AppTokens.fwBold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                        decoration: InputDecoration(
                          suffixText: 'TND',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.space16, vertical: AppTokens.space16),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppTokens.space12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.info, size: 15, color: cs.onSurfaceVariant),
                          const SizedBox(width: AppTokens.space8),
                          Expanded(
                            child: Text(
                              ar
                                  ? 'سيعدّ المسؤول المبلغ أمامك. لا يُعتبر التسليم منتهيا قبل ذلك.'
                                  : 'Le dépôt comptera le montant devant vous. '
                                      'La remise n’est pas terminée avant.',
                              style: TextStyle(
                                  fontSize: 12, height: 1.45, color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
      bottomNavigationBar: (_loading || _error != null || nothingToHandOver)
          ? null
          : Container(
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(AppTokens.space20, AppTokens.space12,
                    AppTokens.space20, AppTokens.space12),
                child: FilledButton.icon(
                  onPressed: (_submitting || _declared <= 0) ? null : () => _submit(locale),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(LucideIcons.banknote, size: 20),
                  label: Text(
                    ar ? 'التصريح بالمبلغ' : 'Déclarer le montant',
                    style: const TextStyle(fontWeight: AppTokens.fwBold, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry, required this.ar});
  final VoidCallback onRetry;
  final bool ar;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.wifiOff, size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppTokens.space12),
            Text(ar ? 'تعذّر التحميل' : 'Chargement impossible'),
            const SizedBox(height: AppTokens.space12),
            OutlinedButton(onPressed: onRetry, child: Text(ar ? 'إعادة المحاولة' : 'Réessayer')),
          ],
        ),
      );
}
