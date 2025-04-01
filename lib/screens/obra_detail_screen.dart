import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/obra_model.dart';
import '../services/obra_service.dart';
import '../services/auth_service.dart';
import '../widgets/image_thumbnails.dart';
import 'obra_form_screen.dart';

class ObraDetailScreen extends StatefulWidget {
  final ObraModel obra;
  final bool isAdmin;

  const ObraDetailScreen({
    super.key,
    required this.obra,
    this.isAdmin = false,
  });

  @override
  State<ObraDetailScreen> createState() => _ObraDetailScreenState();
}

class _ObraDetailScreenState extends State<ObraDetailScreen> {
  final _obraService = ObraService();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;
  late ObraModel _obra;

  @override
  void initState() {
    super.initState();
    _obra = widget.obra;
  }

  void _editarObra() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObraFormScreen(obra: widget.obra),
      ),
    );
    if (result != null) {
      setState(() {
        _obra = result as ObraModel;
      });
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmarExclusao() async {
    final user = _authService.getCurrentUser();
    if (user?.email != 'fetterapp@gmail.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas o administrador pode excluir obras'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            Text('Deseja realmente excluir a Obra #${widget.obra.numero}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      await _obraService.deleteObra(widget.obra.numero);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obra excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir obra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);

      final bytes = await image.readAsBytes();
      final fileName = image.name;

      final obraAtualizada = await _obraService.addImageToObra(
        _obra.numero,
        bytes,
        fileName,
      );

      setState(() {
        _obra = obraAtualizada;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem adicionada com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer upload da imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      await _obraService.deleteImageFromObra(widget.obra.numero, imageUrl);
      setState(() {
        _obra.imageUrls.remove(imageUrl);
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem removida com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    final isAdmin = user?.email == 'fetterapp@gmail.com';

    return Scaffold(
      appBar: AppBar(
        title: Text('Obra #${_obra.numero}'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editarObra,
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmarExclusao,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('Cliente', _obra.cliente),
                  const SizedBox(height: 8),
                  _buildInfoItem('Endereço', _obra.endereco),
                  const SizedBox(height: 8),
                  _buildInfoItem('Descrição', _obra.descricao),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    'Data de Criação',
                    DateFormat('dd/MM/yyyy HH:mm').format(_obra.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Imagens',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate),
                      onPressed: _isLoading ? null : _uploadImage,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_obra.imageUrls.isEmpty)
              const Center(
                child: Text(
                  'Nenhuma imagem cadastrada',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ImageThumbnails(
                imageUrls: _obra.imageUrls,
                isAdmin: isAdmin,
                onDelete: isAdmin ? _deleteImage : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
