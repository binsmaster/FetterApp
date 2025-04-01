import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/obra_model.dart';
import '../theme/app_theme.dart';

class ObraCard extends StatelessWidget {
  final ObraModel obra;
  final VoidCallback onTap;

  const ObraCard({
    super.key,
    required this.obra,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Obra #${obra.numero}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    obra.cliente,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.subtitleColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            obra.endereco,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(obra.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                obra.descricao,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
