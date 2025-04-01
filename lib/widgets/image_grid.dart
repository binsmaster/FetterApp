import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final Function(String)? onImageTap;
  final Function(String)? onDeleteImage;
  final bool isAdmin;

  const ImageGrid({
    super.key,
    required this.imageUrls,
    this.onImageTap,
    this.onDeleteImage,
    this.isAdmin = false,
  });

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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final url = imageUrls[index];
        return Stack(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: onImageTap != null ? () => onImageTap!(url) : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            if (isAdmin && onDeleteImage != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => onDeleteImage!(url),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
