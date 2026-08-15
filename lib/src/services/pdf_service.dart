import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

// Web-only import via conditional
import 'pdf_service_web.dart' if (dart.library.io) 'pdf_service_io.dart';

/// Carries the server's own explanation of why a document could not be produced.
class PdfDownloadException implements Exception {
  const PdfDownloadException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PdfService {
  PdfService(this._client);

  final ApiClient _client;

  /// Downloads a PDF from [path] (relative API path) and opens it.
  /// On mobile: saves to temp dir and opens with system viewer.
  /// On web: triggers browser download.
  ///
  /// Throws [PdfDownloadException] carrying the server's message when the server declined. The
  /// delivery note is served from the ERP and has real reasons to be unavailable — this delivery has
  /// no picking reference, or the ERP is unreachable — and each tells the driver something different.
  /// Collapsing them into one generic "download failed" left him with a button that simply did
  /// nothing, and no way to know whether to retry or to call the office.
  Future<bool> downloadAndOpen(String path, {String fileName = 'document.pdf'}) async {
    try {
      final response = await _client.dio.get<Uint8List>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return false;

      return openPdfBytes(bytes, fileName);
    } on DioException catch (e) {
      debugPrint('[PDF] Download error: $e');
      final message = _serverMessage(e);
      if (message != null) throw PdfDownloadException(message);
      return false;
    } catch (e) {
      debugPrint('[PDF] Download error: $e');
      return false;
    }
  }

  /// The API reports errors as JSON, but the request asked for bytes — so the error body arrives as
  /// bytes as well, and has to be decoded by hand before the message can be read.
  String? _serverMessage(DioException e) {
    final data = e.response?.data;
    try {
      final raw = data is List<int>
          ? utf8.decode(data)
          : (data is String ? data : null);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {
      // Not JSON (an HTML error page, a truncated body): nothing worth showing the driver.
    }
    return null;
  }
}
