import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import '../models/obra_model.dart';

class ObraCarousel extends StatelessWidget {
  final List<ObraModel> obras;

  const ObraCarousel({
    super.key,
    required this.obras,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Altura reduzida para melhor proporção
      child: CarouselSlider(
        slideIndicator: CircularSlideIndicator(
          padding: const EdgeInsets.only(bottom: 8),
          indicatorRadius: 4,
          itemSpacing: 8,
          indicatorBorderWidth: 1,
          indicatorBackgroundColor: Colors.grey.shade300,
          currentIndicatorColor: Theme.of(context).primaryColor,
        ),
        children: obras.map((obra) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          obra.cliente,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      obra.endereco,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        obra.descricao,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
