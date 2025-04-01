import 'package:flutter/material.dart';
import '../services/image_service.dart';
import 'fullscreen_image_viewer.dart';

class ImageThumbnails extends StatelessWidget {
  final List<String> imageUrls;
  final Function(String)? onDelete;
  final bool isAdmin;
  final double thumbnailSize;
  final double spacing;

  const ImageThumbnails({
    super.key,
    required this.imageUrls,
    this.onDelete,
    this.isAdmin = false,
    this.thumbnailSize = 100,
    this.spacing = 8,
  });

  void _viewImage(BuildContext context, String imageUrl, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          imageUrl: imageUrl,
          imageUrls: imageUrls,
          initialIndex: index,
          title: 'Imagem ${index + 1} de ${imageUrls.length}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const Center(
        child: Text('Nenhuma imagem disponível'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.2,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () => _viewImage(context, imageUrl, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageService().buildCachedImage(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isAdmin && onDelete != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => onDelete!(imageUrl),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
