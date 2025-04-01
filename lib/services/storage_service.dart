import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'obras';

  String _generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000; // Usar os últimos 4 dígitos
    final extension = originalFileName.split('.').last;
    return 'img_${timestamp}_$random.$extension';
  }

  Future<String> uploadImage(
      String obraNumero, Uint8List bytes, String fileName) async {
    try {
      print('Iniciando upload da imagem...');
      print('Obra número: $obraNumero');
      print('Nome do arquivo original: $fileName');

      final uniqueFileName = _generateUniqueFileName(fileName);
      print('Nome único gerado: $uniqueFileName');

      final String path = 'obra_$obraNumero/$uniqueFileName';
      print('Caminho do arquivo: $path');

      await _supabase.storage.from(_bucketName).uploadBinary(path, bytes);
      print('Upload concluído com sucesso');

      final String imageUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(path);
      print('URL pública gerada: $imageUrl');

      return imageUrl;
    } catch (e, stackTrace) {
      print('Erro no upload da imagem:');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> deleteImage(String fullPath) async {
    try {
      print('Iniciando exclusão da imagem...');
      print('URL completa: $fullPath');

      // Extrai o caminho relativo da URL completa
      final uri = Uri.parse(fullPath);
      final pathSegments = uri.pathSegments;
      print('Segmentos do caminho: $pathSegments');

      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1) {
        throw Exception('URL inválida: bucket não encontrado');
      }

      final relativePath = pathSegments.sublist(bucketIndex + 1).join('/');
      print('Caminho relativo: $relativePath');

      await _supabase.storage.from(_bucketName).remove([relativePath]);
      print('Imagem excluída com sucesso');
    } catch (e, stackTrace) {
      print('Erro na exclusão da imagem:');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erro ao excluir imagem: $e');
    }
  }

  Future<List<String>> getObraImages(String obraNumero) async {
    try {
      print('Buscando imagens da obra $obraNumero...');

      final List<FileObject> files = await _supabase.storage
          .from(_bucketName)
          .list(path: 'obra_$obraNumero');
      print('Arquivos encontrados: ${files.length}');

      final urls = files.map((file) {
        final url = _supabase.storage
            .from(_bucketName)
            .getPublicUrl('obra_$obraNumero/${file.name}');
        print('URL gerada para ${file.name}: $url');
        return url;
      }).toList();

      print('URLs geradas: $urls');
      return urls;
    } catch (e, stackTrace) {
      print('Erro ao buscar imagens:');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erro ao buscar imagens da obra: $e');
    }
  }
}
