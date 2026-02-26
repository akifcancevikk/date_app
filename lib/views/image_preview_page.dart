import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/models/memory_model.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:image_preview/preview_data.dart';
import 'package:photo_viewer/photo_viewer.dart';

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
  late int _currentIndex;
  late List<PreviewData> _data;
  late List<String> _notes;
  void Function(int)? _jumpToPage;
  bool _isDeleting = false;
  MemoryModel? _updatedMemory;

  @override
  void initState() {
    super.initState();
    // Initialize paging and local state.
    _currentIndex = widget.initialIndex;
    _data = List.of(widget.data);
    _notes = List.of(widget.notes);
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _baseUrlFromImageUrl(String imageUrl) {
    // Extract base endpoint so we can rebuild URLs after deletion.
    final index = imageUrl.indexOf('/image/');
    if (index == -1) return imageUrl;
    return imageUrl.substring(0, index);
  }

  String _imageNameFromUrl(String imageUrl) {
    // Extract filename from the URL path.
    try {
      return Uri.parse(imageUrl).pathSegments.last;
    } catch (_) {
      return '';
    }
  }

  List<PreviewData> _buildPreviewData(String baseUrl, List<String> paths) {
    // Rebuild preview list from updated server data.
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
    // Delete the currently visible image from the server.
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
      _jumpToPage?.call(_currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen preview with swipe, close, delete, and thumbnail strip.
    final builders = _data
        .where((p) => (p.image?.url ?? '').isNotEmpty)
        .map<WidgetBuilder>((p) {
      final url = p.image?.url ?? '';
      return (context) => Center(
            child: CachedNetworkImage(
              imageUrl: url,
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
    }).toList();

    return DismissiblePage(
      direction: DismissiblePageDismissDirection.down,
      onDismissed: () => Navigator.of(context).pop(_updatedMemory),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: PhotoViewerScreen(
            builders: builders,
            initialPage: _currentIndex,
            enableVerticalDismiss: false,
            showDefaultCloseButton: false,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            onJumpToPage: (jumpToPage) {
              _jumpToPage = jumpToPage;
            },
            overlayBuilder: (context) {
              return Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _CloseButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_updatedMemory),
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
                      onTap: _jumpToPage,
                      isVisible: true,
                    ),
                  ),
                ],
              );
            },
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
  final void Function(int)? onTap;
  final bool isVisible;

  const _ThumbnailBar({
    required this.data,
    required this.currentIndex,
    required this.onTap,
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
                    onTap?.call(index);
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
