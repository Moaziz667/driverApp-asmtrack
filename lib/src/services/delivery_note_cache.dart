import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Offline copy of the delivery-note PDFs (bons de livraison).
///
/// The note is produced by the ERP, not by ASM, so opening one is a live call — and it is the
/// document the customer signs for, which makes the doorstep the worst possible moment to depend on
/// signal. It is therefore fetched ahead of time, while the driver is still at the depot, exactly as
/// the deliveries themselves are.
///
/// Kept in its own box: these are binary blobs of a few hundred kilobytes each, so they must be
/// prunable without touching the rest of the offline cache.
class DeliveryNoteCache {
  static const boxName = 'delivery_notes';

  Box<Uint8List> get _box => Hive.box<Uint8List>(boxName);

  Uint8List? get(String deliveryId) {
    try {
      return _box.get(deliveryId);
    } catch (_) {
      return null;
    }
  }

  bool has(String deliveryId) => get(deliveryId) != null;

  Future<void> put(String deliveryId, Uint8List bytes) async {
    try {
      await _box.put(deliveryId, bytes);
    } catch (e) {
      debugPrint('[BL cache] write failed for $deliveryId: $e');
    }
  }

  /// Drop every note that is not in [keep] — yesterday's round is dead weight on the handset.
  Future<void> retainOnly(Set<String> keep) async {
    try {
      final stale = _box.keys.map((k) => k.toString()).where((k) => !keep.contains(k)).toList();
      if (stale.isEmpty) return;
      await _box.deleteAll(stale);
      debugPrint('[BL cache] pruned ${stale.length} stale note(s)');
    } catch (e) {
      debugPrint('[BL cache] prune failed: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (_) {}
  }
}
