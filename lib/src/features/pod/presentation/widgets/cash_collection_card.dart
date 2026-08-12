import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/tokens.dart';
import '../../../deliveries/models/delivery_models.dart';

/// How the customer settled. Mirrors the server enum.
enum CashMethod { cash, cheque, none }

extension CashMethodX on CashMethod {
  String get api => switch (this) {
        CashMethod.cash => 'CASH',
        CashMethod.cheque => 'CHEQUE',
        CashMethod.none => 'NONE',
      };
}

/// Everything the driver reported at the door, handed back to the form as one value.
class CashFormState {
  const CashFormState({
    required this.method,
    required this.amount,
    this.chequeNumber,
    this.chequeBank,
    this.chequeDate,
    this.reasonCode,
  });

  final CashMethod method;
  final double amount;
  final String? chequeNumber;
  final String? chequeBank;
  final DateTime? chequeDate;
  final String? reasonCode;

  CashEntry toEntry() => CashEntry(
        amountCollected: amount,
        method: method.api,
        chequeNumber: chequeNumber,
        chequeBank: chequeBank,
        chequeDate: chequeDate != null
            ? '${chequeDate!.year.toString().padLeft(4, '0')}-'
                '${chequeDate!.month.toString().padLeft(2, '0')}-'
                '${chequeDate!.day.toString().padLeft(2, '0')}'
            : null,
        reason: reasonCode,
      );
}

/// Money collected at the door.
///
/// Shown only when the order carries an instruction: a card on every non-COD delivery would be noise
/// on the one screen a driver fills in standing up, in the sun, with a van door open behind him.
///
/// The screen states the amount before it asks anything. A driver who has to work out what to
/// collect from an order total is a driver who will occasionally work it out wrong, and there is no
/// second chance once he has driven away.
class CashCollectionCard extends StatefulWidget {
  const CashCollectionCard({
    super.key,
    required this.expected,
    required this.currency,
    required this.reasons,
    required this.onChanged,
    this.locale = 'fr',
  });

  final double expected;
  final String currency;

  /// Admin reason catalogue, filtered to the payment scope at the point of use. Empty offline — the
  /// card then accepts a shortfall without one rather
  /// than dead-locking the driver, exactly like the item cards do.
  final List<FailureReasonOption> reasons;
  final ValueChanged<CashFormState> onChanged;
  final String locale;

  @override
  State<CashCollectionCard> createState() => _CashCollectionCardState();
}

class _CashCollectionCardState extends State<CashCollectionCard> {
  late final TextEditingController _amountCtrl;
  final _chequeNumberCtrl = TextEditingController();
  final _chequeBankCtrl = TextEditingController();

  CashMethod _method = CashMethod.cash;
  DateTime? _chequeDate;
  String? _reasonCode;

  @override
  void initState() {
    super.initState();
    // Pre-filled with the expected amount: the common case by far is "he paid it all", and making
    // that case one tap instead of eleven digits is the difference between a field filled correctly
    // and one filled quickly.
    _amountCtrl = TextEditingController(text: _format(widget.expected));
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _chequeNumberCtrl.dispose();
    _chequeBankCtrl.dispose();
    super.dispose();
  }

  static String _format(double v) => v.toStringAsFixed(3).replaceAll('.', ',');

  /// Accepts both separators.
  ///
  /// A Tunisian driver types on a keyboard whose decimal key is a comma, and a field that silently
  /// refuses it looks broken rather than strict.
  double get _amount {
    final raw = _amountCtrl.text.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (raw.isEmpty) return 0;
    return double.tryParse(raw) ?? 0;
  }

  bool get _isShort => _method == CashMethod.none || _amount < widget.expected;

  /// Only demand a motif when the catalogue actually offers one — offline it is empty, and blocking
  /// the proof of a delivery that physically happened is never the right trade.
  bool get _reasonAvailable => widget.reasons.any((r) => r.coversPayment);

  bool get isValid {
    if (_method == CashMethod.cheque && _chequeNumberCtrl.text.trim().isEmpty) return false;
    if (_isShort && _reasonAvailable && _reasonCode == null) return false;
    return true;
  }

  void _emit() {
    widget.onChanged(CashFormState(
      method: _method,
      amount: _method == CashMethod.none ? 0 : _amount,
      chequeNumber: _method == CashMethod.cheque ? _chequeNumberCtrl.text.trim() : null,
      chequeBank: _method == CashMethod.cheque ? _chequeBankCtrl.text.trim() : null,
      chequeDate: _method == CashMethod.cheque ? _chequeDate : null,
      reasonCode: _isShort ? _reasonCode : null,
    ));
  }

  bool get _ar => widget.locale == 'ar';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final short = _isShort;

    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(color: short ? AppTokens.warningAmber : cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── The instruction, before any input ────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTokens.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: const Icon(LucideIcons.banknote, size: 18, color: AppTokens.successGreen),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ar ? 'المبلغ المطلوب' : 'À encaisser',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: AppTokens.fwMedium,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _format(widget.expected),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: AppTokens.fwBold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: AppTokens.space6),
                        Text(
                          widget.currency,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: AppTokens.fwMedium,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTokens.space16),

          // ── How he was paid ─────────────────────────────────────────────
          SegmentedButton<CashMethod>(
            segments: [
              ButtonSegment(
                value: CashMethod.cash,
                icon: const Icon(LucideIcons.banknote, size: 16),
                label: Text(_ar ? 'نقدا' : 'Espèces'),
              ),
              ButtonSegment(
                value: CashMethod.cheque,
                icon: const Icon(LucideIcons.fileText, size: 16),
                label: Text(_ar ? 'شيك' : 'Chèque'),
              ),
              ButtonSegment(
                value: CashMethod.none,
                icon: const Icon(LucideIcons.x, size: 16),
                label: Text(_ar ? 'لا شيء' : 'Rien'),
              ),
            ],
            selected: {_method},
            showSelectedIcon: false,
            onSelectionChanged: (s) {
              setState(() {
                _method = s.first;
                if (_method == CashMethod.none) {
                  _amountCtrl.text = _format(0);
                } else if (_amount == 0) {
                  _amountCtrl.text = _format(widget.expected);
                }
              });
              _emit();
            },
          ),

          if (_method != CashMethod.none) ...[
            const SizedBox(height: AppTokens.space14),
            _Label(_ar ? 'المبلغ المقبوض' : 'Montant reçu'),
            const SizedBox(height: AppTokens.space6),
            TextField(
              controller: _amountCtrl,
              // Comma-friendly: the decimal key on a French/Arabic keyboard is a comma, and a
              // `number` keyboard that rejects it makes the field look broken.
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: AppTokens.fwSemiBold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              decoration: InputDecoration(
                suffixText: widget.currency,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space12, vertical: AppTokens.space12),
              ),
              onChanged: (_) { setState(() {}); _emit(); },
            ),
          ],

          if (_method == CashMethod.cheque) ...[
            const SizedBox(height: AppTokens.space12),
            // A cheque with no number cannot be traced back to the delivery that took it, which is
            // the entire reason a cheque is worth recording separately from cash.
            _Label(_ar ? 'رقم الشيك' : 'N° du chèque'),
            const SizedBox(height: AppTokens.space6),
            TextField(
              controller: _chequeNumberCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1234567',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space12, vertical: AppTokens.space10),
              ),
              onChanged: (_) { setState(() {}); _emit(); },
            ),
            const SizedBox(height: AppTokens.space10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label(_ar ? 'البنك' : 'Banque'),
                      const SizedBox(height: AppTokens.space6),
                      TextField(
                        controller: _chequeBankCtrl,
                        decoration: InputDecoration(
                          hintText: 'BIAT',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.space12, vertical: AppTokens.space10),
                        ),
                        onChanged: (_) => _emit(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTokens.space10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label(_ar ? 'التاريخ' : 'Date'),
                      const SizedBox(height: AppTokens.space6),
                      OutlinedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _chequeDate ?? now,
                            firstDate: now.subtract(const Duration(days: 365)),
                            lastDate: now.add(const Duration(days: 365 * 2)),
                          );
                          if (picked != null) {
                            setState(() => _chequeDate = picked);
                            _emit();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                        ),
                        child: Text(
                          _chequeDate == null
                              ? (_ar ? 'اختر' : 'Choisir')
                              : '${_chequeDate!.day.toString().padLeft(2, '0')}/'
                                  '${_chequeDate!.month.toString().padLeft(2, '0')}/'
                                  '${_chequeDate!.year}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // ── The shortfall, named ────────────────────────────────────────
          if (short) ...[
            const SizedBox(height: AppTokens.space14),
            Container(
              padding: const EdgeInsets.all(AppTokens.space10),
              decoration: BoxDecoration(
                color: AppTokens.warningAmber.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 15, color: AppTokens.warningAmber),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      _ar ? 'ناقص' : 'Manquant',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: AppTokens.fwMedium,
                          color: cs.onSurfaceVariant),
                    ),
                  ),
                  // The minus sign carries the meaning; the colour only reinforces it.
                  Text(
                    '−${_format(widget.expected - (_method == CashMethod.none ? 0 : _amount))} ${widget.currency}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: AppTokens.fwBold,
                      color: AppTokens.warningAmber,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (_reasonAvailable) ...[
              const SizedBox(height: AppTokens.space12),
              _Label(_ar ? 'السبب' : 'Motif'),
              const SizedBox(height: AppTokens.space6),
              Wrap(
                spacing: AppTokens.space8,
                runSpacing: AppTokens.space8,
                children: widget.reasons.where((r) => r.coversPayment).map((r) {
                  final selected = _reasonCode == r.code;
                  return ChoiceChip(
                    label: Text(r.label, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _reasonCode = selected ? null : r.code);
                      _emit();
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: AppTokens.fwMedium,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
}
