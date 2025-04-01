import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../models/obra_model.dart';
import '../services/obra_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class ObraFormScreen extends StatefulWidget {
  final ObraModel? obra;

  const ObraFormScreen({
    super.key,
    this.obra,
  });

  @override
  State<ObraFormScreen> createState() => _ObraFormScreenState();
}

class _ObraFormScreenState extends State<ObraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _numeroFocus = FocusNode();
  final _clienteController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _obraService = ObraService();
  bool _isLoading = false;
  List<List<int>> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.obra != null) {
      _numeroController.text = widget.obra!.numero.toString();
      _clienteController.text = widget.obra!.cliente;
      _enderecoController.text = widget.obra!.endereco;
      _descricaoController.text = widget.obra!.descricao;
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        List<List<int>> imageBytesList = [];
        for (var image in images) {
          final bytes = await image.readAsBytes();
          imageBytesList.add(bytes);
        }
        setState(() {
          _selectedImages.addAll(imageBytesList);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagens: $e')),
      );
    }
  }

  Future<void> _saveObra() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final numero = int.parse(_numeroController.text);

      late ObraModel obra;
      if (widget.obra == null) {
        print('Criando nova obra...');
        // Criar nova obra
        obra = await _obraService.createObra(ObraModel(
          numero: numero,
          cliente: _clienteController.text,
          endereco: _enderecoController.text,
          descricao: _descricaoController.text,
          createdAt: DateTime.now(),
          imageUrls: [], // Inicializa com array vazio
        ));
        print('Obra criada com sucesso: ${obra.numero}');

        // Upload das imagens uma por uma
        if (_selectedImages.isNotEmpty) {
          print('Iniciando upload de ${_selectedImages.length} imagens...');
          for (var imageBytes in _selectedImages) {
            try {
              print('Fazendo upload da imagem');
              obra = await _obraService.addImageToObra(
                obra.numero,
                Uint8List.fromList(imageBytes),
                'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
              print('Upload concluído com sucesso');
            } catch (e) {
              print('Erro no upload da imagem: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao fazer upload da imagem: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Obra cadastrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, obra);
        }
      } else {
        // Confirmar atualização
        if (mounted) {
          final confirmarAtualizacao = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar Atualização'),
              content: const Text('Deseja realmente atualizar esta obra?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Atualizar'),
                ),
              ],
            ),
          );

          if (confirmarAtualizacao != true) {
            setState(() => _isLoading = false);
            return;
          }
        }

        obra = await _obraService.updateObra(ObraModel(
          numero: numero,
          cliente: _clienteController.text,
          endereco: _enderecoController.text,
          descricao: _descricaoController.text,
          createdAt: widget.obra!.createdAt,
          imageUrls: widget.obra!.imageUrls,
        ));

        // Upload das novas imagens
        if (_selectedImages.isNotEmpty) {
          print(
              'Iniciando upload de ${_selectedImages.length} novas imagens...');
          for (var imageBytes in _selectedImages) {
            try {
              print('Fazendo upload da imagem');
              obra = await _obraService.addImageToObra(
                obra.numero,
                Uint8List.fromList(imageBytes),
                'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
              print('Upload concluído com sucesso');
            } catch (e) {
              print('Erro no upload da imagem: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao fazer upload da imagem: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Obra atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, obra);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final errorMessage = e.toString().contains('Já existe uma obra')
            ? 'Já existe uma obra com este número. Por favor, escolha outro número.'
            : 'Erro ao salvar obra: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.obra == null ? 'Nova Obra' : 'Editar Obra'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _numeroController,
              focusNode: _numeroFocus,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número da Obra',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o número da obra';
                }
                try {
                  final numero = int.parse(value);
                  if (numero <= 0) {
                    return 'O número deve ser maior que zero';
                  }
                } catch (e) {
                  return 'Por favor, insira apenas números';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clienteController,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome do cliente';
                }
                if (value.length < 3) {
                  return 'O nome do cliente deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _enderecoController,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o endereço';
                }
                if (value.length < 5) {
                  return 'O endereço deve ter pelo menos 5 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma descrição';
                }
                if (value.length < 10) {
                  return 'A descrição deve ter pelo menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Seção de upload de imagens
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Imagens',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              Image.memory(
                                Uint8List.fromList(_selectedImages[index]),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    color: Colors.white,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Adicionar Imagens'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveObra,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  widget.obra == null ? 'Criar Obra' : 'Salvar Alterações',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _numeroFocus.dispose();
    _clienteController.dispose();
    _enderecoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}
