import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/obra_model.dart';
import 'image_service.dart';

class ObraService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImageService _imageService = ImageService();

  Future<bool> numeroJaExiste(int numero) async {
    try {
      final response = await _supabase
          .from('obras')
          .select('numero')
          .eq('numero', numero)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Erro ao verificar número: $e');
      rethrow;
    }
  }

  Future<List<ObraModel>> getObras() async {
    try {
      print('Buscando obras...');
      final response = await _supabase
          .from('obras')
          .select(
              'numero, cliente, endereco, descricao, created_at, image_urls')
          .order('created_at', ascending: false);

      print('Resposta do Supabase: $response');

      final obras =
          (response as List).map((obra) => ObraModel.fromJson(obra)).toList();

      print('Obras convertidas: ${obras.length}');
      return obras;
    } catch (e) {
      print('Erro ao buscar obras: $e');
      rethrow;
    }
  }

  Future<ObraModel> createObra(ObraModel obra) async {
    try {
      print('Verificando se número ${obra.numero} já existe...');
      if (await numeroJaExiste(obra.numero)) {
        throw Exception('Já existe uma obra com o número ${obra.numero}');
      }
      print('Número disponível, criando obra...');

      final response = await _supabase.from('obras').insert({
        'numero': obra.numero,
        'cliente': obra.cliente,
        'endereco': obra.endereco,
        'descricao': obra.descricao,
        'image_urls': obra.imageUrls,
      }).select();

      return ObraModel.fromJson(response.first);
    } catch (e) {
      print('Erro ao criar obra: $e');
      rethrow;
    }
  }

  Future<ObraModel> updateObra(ObraModel obra) async {
    try {
      final response = await _supabase
          .from('obras')
          .update({
            'cliente': obra.cliente,
            'endereco': obra.endereco,
            'descricao': obra.descricao,
            'image_urls': obra.imageUrls,
          })
          .eq('numero', obra.numero)
          .select();

      return ObraModel.fromJson(response.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteObra(int numero) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user?.email != 'fetterapp@gmail.com') {
        throw Exception('Apenas o administrador pode excluir obras');
      }

      // Busca a obra para obter as URLs das imagens
      final response = await _supabase
          .from('obras')
          .select('image_urls')
          .eq('numero', numero)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        throw Exception('Obra não encontrada');
      }

      // Exclui as imagens do storage
      if (response['image_urls'] != null) {
        final List<String> imageUrls =
            List<String>.from(response['image_urls']);
        print('Excluindo ${imageUrls.length} imagens do storage...');
        for (var url in imageUrls) {
          try {
            await _imageService.deleteImage(url);
            print('Imagem excluída com sucesso: $url');
          } catch (e) {
            print('Erro ao excluir imagem $url: $e');
            // Continua excluindo as outras imagens mesmo se uma falhar
          }
        }
      }

      // Exclui a obra
      await _supabase.from('obras').delete().eq('numero', numero);

      print('Obra $numero excluída com sucesso');
    } catch (e) {
      print('Erro ao excluir obra: $e');
      if (e.toString().contains('Row not found')) {
        throw Exception('Obra não encontrada');
      }
      rethrow;
    }
  }

  Future<ObraModel> addImageToObra(
      int numero, Uint8List fileBytes, String fileName) async {
    try {
      // Faz o upload da imagem e obtém a URL
      final imageUrl = await _imageService.uploadImage(
        numero.toString(),
        fileBytes,
        fileName,
      );

      // Obtém a obra atual
      final obra = await getObra(numero);

      // Adiciona a nova URL à lista existente
      final List<String> updatedImageUrls = List.from(obra.imageUrls)
        ..add(imageUrl);

      // Atualiza a obra com a nova lista de URLs
      final response = await _supabase
          .from('obras')
          .update({'image_urls': updatedImageUrls})
          .eq('numero', numero)
          .select();

      return ObraModel.fromJson(response.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImageFromObra(int numero, String imageUrl) async {
    try {
      // Primeiro, obtém a obra atual
      final obra = await getObra(numero);

      // Remove a URL da imagem da lista
      final List<String> updatedImageUrls = List.from(obra.imageUrls)
        ..remove(imageUrl);

      // Atualiza a obra com a nova lista de URLs
      await _supabase
          .from('obras')
          .update({'image_urls': updatedImageUrls}).eq('numero', numero);

      // Deleta a imagem do storage
      await _imageService.deleteImage(imageUrl);
    } catch (e) {
      rethrow;
    }
  }

  Future<ObraModel> getObra(int numero) async {
    try {
      final response =
          await _supabase.from('obras').select().eq('numero', numero).single();

      return ObraModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
