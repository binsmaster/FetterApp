import 'package:flutter/material.dart';
import '../models/obra_model.dart';
import '../services/obra_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/obra_card.dart';
import 'login_screen.dart';
import 'obra_detail_screen.dart';
import 'obra_form_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _obraService = ObraService();
  final _authService = AuthService();
  List<ObraModel> _obras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObras();
  }

  Future<void> _loadObras() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final obras = await _obraService.getObras();
      if (!mounted) return;

      setState(() {
        _obras = obras;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar obras: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmarExclusao(ObraModel obra) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir a Obra #${obra.numero}?'),
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
      await _obraService.deleteObra(obra.numero);
      _loadObras(); // Recarrega a lista
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obra excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _abrirFormulario() async {
    final result = await Navigator.push<ObraModel>(
      context,
      MaterialPageRoute(builder: (context) => const ObraFormScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _obras.removeWhere((obra) => obra.numero == result.numero);
        _obras.insert(0, result);
      });
      _loadObras();
    }
  }

  void _abrirDetalhes(ObraModel obra) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ObraDetailScreen(obra: obra),
      ),
    );

    if (result != null && mounted) {
      if (result is ObraModel) {
        setState(() {
          final index = _obras.indexWhere((o) => o.numero == result.numero);
          if (index != -1) {
            _obras[index] = result;
          }
        });
      }
      _loadObras();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    final isAdmin = user?.email == 'fetterapp@gmail.com';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Text(
                      (user?.name ?? user?.email ?? 'V')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Olá, ${user?.name ?? user?.email ?? 'Visitante'}',
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadObras,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Todas as Obras',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${_obras.length} ${_obras.length == 1 ? 'obra' : 'obras'}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.subtitleColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _obras.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.construction,
                                  size: 64,
                                  color: AppTheme.subtitleColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma obra cadastrada',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.subtitleColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _abrirFormulario,
                                  child: Text(
                                    'Adicionar Nova Obra',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _obras.length,
                            itemBuilder: (context, index) {
                              final obra = _obras[index];
                              return Dismissible(
                                key: Key(obra.numero.toString()),
                                direction: isAdmin
                                    ? DismissDirection.endToStart
                                    : DismissDirection.none,
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    await _confirmarExclusao(obra);
                                    return false;
                                  }
                                  return false;
                                },
                                background: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: ObraCard(
                                  obra: obra,
                                  onTap: () => _abrirDetalhes(obra),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }
}
