import 'dart:io';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class ModelDownloadResult {
  final String filePath;
  final int bytes;

  ModelDownloadResult({required this.filePath, required this.bytes});
}

class ModelDownloadService {
  final Dio _dio;

  ModelDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  Future<ModelDownloadResult> download(
    String url, {
    required String fileName,
    required void Function(int received, int total) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/ml/models');
    if (!modelsDir.existsSync()) {
      modelsDir.createSync(recursive: true);
    }

    final filePath = '${modelsDir.path}/$fileName';
    final file = File(filePath);

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: onProgress,
    );

    final bytes = await file.length();
    return ModelDownloadResult(filePath: filePath, bytes: bytes);
  }

  Future<String> sha256OfFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
