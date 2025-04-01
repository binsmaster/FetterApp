import 'package:flutter/material.dart';
import '../services/image_service.dart';

class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final List<String>? imageUrls;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    this.title,
    this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  final _imageService = ImageService();
  final TransformationController _transformationController =
      TransformationController();
  late PageController _pageController;
  late int _currentIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _preloadImage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadImage() async {
    try {
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _resetZoom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls ?? [widget.imageUrl];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text(
            widget.title ?? 'Imagem ${_currentIndex + 1} de ${images.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetZoom,
            tooltip: 'Resetar Zoom',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: _imageService.buildCachedImage(
                      images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(
                        _currentIndex == index ? 0.9 : 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
