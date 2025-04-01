import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/image_service.dart';
import 'fullscreen_image_viewer.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  final Function(String)? onDelete;
  final bool isAdmin;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 300,
    this.autoPlay = false,
    this.onDelete,
    this.isAdmin = false,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final CarouselController _controller = CarouselController();
  final _imageService = ImageService();
  int _currentIndex = 0;

  void _viewImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          imageUrl: imageUrl,
          title: 'Imagem ${_currentIndex + 1} de ${widget.imageUrls.length}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('Nenhuma imagem disponível'),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: widget.height,
                  autoPlay: widget.autoPlay,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
                items: widget.imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () => _viewImage(imageUrl),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _imageService.buildCachedImage(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              if (widget.isAdmin)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: widget.onDelete != null
                        ? () =>
                            widget.onDelete!(widget.imageUrls[_currentIndex])
                        : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                  _currentIndex == entry.key ? 0.9 : 0.4,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
