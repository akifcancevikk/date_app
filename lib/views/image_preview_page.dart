import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/models/memory_model.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:image_preview/preview_data.dart';

class ImagePreviewPage extends StatefulWidget {
  final List<PreviewData> data;
  final int initialIndex;
  final int memoryId;
  final List<String> notes;

  const ImagePreviewPage({
    super.key,
    required this.data,
    required this.initialIndex,
    required this.memoryId,
    required this.notes,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late final PageController _controller;
  late int _currentIndex;
  late List<PreviewData> _data;
  late List<String> _notes;
  bool _showThumbnails = true;
  bool _isDeleting = false;
  MemoryModel? _updatedMemory;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _data = List.of(widget.data);
    _notes = List.of(widget.notes);
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleThumbnails() {
    setState(() => _showThumbnails = !_showThumbnails);
  }

  String _baseUrlFromImageUrl(String imageUrl) {
    final index = imageUrl.indexOf('/image/');
    if (index == -1) return imageUrl;
    return imageUrl.substring(0, index);
  }

  String _imageNameFromUrl(String imageUrl) {
    try {
      return Uri.parse(imageUrl).pathSegments.last;
    } catch (_) {
      return '';
    }
  }

  List<PreviewData> _buildPreviewData(String baseUrl, List<String> paths) {
    return paths.asMap().entries.map((entry) {
      final index = entry.key;
      final imageName = entry.value;
      final imageUrl = '$baseUrl/image/$imageName';

      return PreviewData(
        type: Type.image,
        heroTag: index.toString(),
        image: ImageData(
          url: imageUrl,
          thumbnailUrl: imageUrl,
        ),
      );
    }).toList();
  }

  Future<void> _deleteCurrentImage() async {
    if (_isDeleting || _data.isEmpty) return;

    final imageUrl = _data[_currentIndex].image?.url ?? '';
    final imageName = _imageNameFromUrl(imageUrl);

    if (imageName.isEmpty) return;

    setState(() => _isDeleting = true);

    final updatedMemory = await deleteImage(
      context,
      widget.memoryId,
      imageName,
      _notes,
    );

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (updatedMemory == null) return;

    _updatedMemory = updatedMemory;
    _notes = List.of(updatedMemory.notes);

    if (updatedMemory.paths.isEmpty) {
      Navigator.of(context).pop(_updatedMemory);
      return;
    }

    final baseUrl = _baseUrlFromImageUrl(imageUrl);
    final newData = _buildPreviewData(baseUrl, updatedMemory.paths);

    setState(() {
      _data = newData;
      if (_currentIndex >= _data.length) {
        _currentIndex = _data.length - 1;
      }
      _controller.jumpToPage(_currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      direction: DismissiblePageDismissDirection.down,
      onDismissed: () => Navigator.of(context).pop(_updatedMemory),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleThumbnails,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _data.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final image = _data[index].image;
                      return Center(
                        child: CachedNetworkImage(
                          imageUrl: image?.url ?? '',
                          httpHeaders: {
                            "Authorization": "Bearer ${Login.userToken}",
                            "Accept": "application/json",
                          },
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _CloseButton(
                  onPressed: () => Navigator.of(context).pop(_updatedMemory),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _DeleteButton(
                  onPressed: _isDeleting ? null : _deleteCurrentImage,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ThumbnailBar(
                  data: _data,
                  currentIndex: _currentIndex,
                  controller: _controller,
                  isVisible: _showThumbnails,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.close, color: Colors.white),
        tooltip: 'Close',
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _DeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.delete, color: Colors.white),
        tooltip: 'Delete',
      ),
    );
  }
}

class _ThumbnailBar extends StatelessWidget {
  final List<PreviewData> data;
  final int currentIndex;
  final PageController controller;
  final bool isVisible;

  const _ThumbnailBar({
    required this.data,
    required this.currentIndex,
    required this.controller,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: isVisible ? 96 : 0,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isVisible ? 12 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        boxShadow: isVisible
            ? [
                const BoxShadow(
                  color: Colors.black54,
                  blurRadius: 18,
                  offset: Offset(0, -6),
                ),
              ]
            : null,
      ),
      child: isVisible
          ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final image = data[index].image;
                final isSelected = index == currentIndex;

                return GestureDetector(
                  onTap: () {
                    controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: image?.thumbnailUrl ?? image?.url ?? '',
                        httpHeaders: {
                          "Authorization": "Bearer ${Login.userToken}",
                          "Accept": "application/json",
                        },
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ColoredBox(
                          color: Colors.black38,
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : null,
    );
  }
}
