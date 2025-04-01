import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'obras';
  final String _profileBucketName = 'profiles';

  String _generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000;
    final extension = originalFileName.split('.').last;
    return 'img_${timestamp}_$random.$extension';
  }

  Future<String> uploadImage(
      String prefix, Uint8List bytes, String fileName) async {
    try {
      final uniqueFileName = _generateUniqueFileName(fileName);
      final String bucketName =
          prefix == 'profile' ? _profileBucketName : _bucketName;
      final String path =
          prefix == 'profile' ? uniqueFileName : 'obra_$prefix/$uniqueFileName';

      // Compressão da imagem antes do upload
      final compressedBytes = await _compressImage(bytes);

      await _supabase.storage
          .from(bucketName)
          .uploadBinary(path, compressedBytes);

      final String imageUrl =
          _supabase.storage.from(bucketName).getPublicUrl(path);

      return imageUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> deleteImage(String fullPath) async {
    try {
      final uri = Uri.parse(fullPath);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(_bucketName);
      final profileBucketIndex = pathSegments.indexOf(_profileBucketName);

      String bucketName;
      List<String> relevantSegments;

      if (bucketIndex != -1) {
        bucketName = _bucketName;
        relevantSegments = pathSegments.sublist(bucketIndex + 1);
      } else if (profileBucketIndex != -1) {
        bucketName = _profileBucketName;
        relevantSegments = pathSegments.sublist(profileBucketIndex + 1);
      } else {
        throw Exception('URL inválida: bucket não encontrado');
      }

      final relativePath = relevantSegments.join('/');
      await _supabase.storage.from(bucketName).remove([relativePath]);
    } catch (e) {
      throw Exception('Erro ao excluir imagem: $e');
    }
  }

  Future<List<String>> getObraImages(String obraNumero) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(_bucketName)
          .list(path: 'obra_$obraNumero');

      final urls = files.map((file) {
        final url = _supabase.storage
            .from(_bucketName)
            .getPublicUrl('obra_$obraNumero/${file.name}');
        return url;
      }).toList();

      return urls;
    } catch (e) {
      throw Exception('Erro ao buscar imagens da obra: $e');
    }
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    // TODO: Implementar compressão de imagem
    // Por enquanto, retorna os bytes originais
    return bytes;
  }

  Widget buildCachedImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Erro ao carregar imagem: $error');
        return const Icon(
          Icons.error_outline,
          color: Colors.red,
        );
      },
      cacheWidth: kIsWeb ? null : 800, // Limita o cache no web
      cacheHeight: kIsWeb ? null : 800,
    );
  }
}
