// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:date_app/models/memory_model.dart';
import 'package:date_app/widgets/dialogs/app_fluid_dialog.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_preview/preview_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:date_app/views/image_preview_page.dart';
import 'package:pie_menu/pie_menu.dart';


class DetailPage extends StatefulWidget {
  final MemoryModel memory;

  const DetailPage({super.key, required this.memory});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isUploading = false;
  final TextEditingController noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<PreviewData> dataList = [];

  static String baseImageUrl =
      '${Url.memories}memories';

  @override
  void initState() {
    super.initState();
    // Build preview list once when page loads.
    _buildPreviewList();
  }

  // Build preview data used by the image preview gallery.
  Future<void> _buildPreviewList() async {
    String path = '';
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        path = ((await getExternalCacheDirectories())?[0].path ?? '');
      } else {
        path = (await getTemporaryDirectory()).path;
      }
    }

    final temp = widget.memory.paths.asMap().entries.map((entry) {
      final index = entry.key;
      final imageName = entry.value;

      final imageUrl = '$baseImageUrl/${widget.memory.id}/image/$imageName';

      final localPath = '$path/$imageName';

      return PreviewData(
        type: Type.image,
        heroTag: index.toString(),
        image: ImageData(
          url: imageUrl,
          path: localPath,
          thumbnailUrl: imageUrl,
          thumbnailPath: localPath,
        ),
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      dataList
        ..clear()
        ..addAll(temp);
    });
  }

  // Pick images from device and upload them to the server.
  Future<void> pickAndUploadImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result == null) return;

      final files = result.paths
          .whereType<String>()
          .map((e) => File(e))
          .toList();

      if (files.isEmpty) return;

      setState(() => isUploading = true);

      final updatedMemory = await updateImage(
        context,
        widget.memory.id,
        files,
      );

      if (updatedMemory != null) {
        setState(() {
          widget.memory.paths
            ..clear()
            ..addAll(updatedMemory.paths);
        });

        await _buildPreviewList();
        successMessage(context, AppStrings.imageAdded);
      }
    } catch (e) {
      errorMessage(context, e.toString());
    } finally {
      setState(() => isUploading = false);
    }
  }

  // Add a new note to the memory and sync with the server.
  Future<void> addNote() async {
    final text = noteController.text.trim();
    if (text.isEmpty) return;

    final updatedNotes = List<String>.from(widget.memory.notes)
      ..add(text);

    final updatedMemory = await updateNote(
      context,
      widget.memory.id,
      updatedNotes,
    );

    if (updatedMemory != null) {
      setState(() {
        widget.memory.notes
          ..clear()
          ..addAll(updatedMemory.notes);
      });

      noteController.clear();
      successMessage(context, AppStrings.noteAdded);
    }
  }

  // Pull-to-refresh: re-sync current note set and refresh local data.
  Future<void> _refreshDetail() async {
    final updatedMemory = await updateDetail(
      context,
      widget.memory.id,
      List<String>.from(widget.memory.notes),
    );

    if (!mounted || updatedMemory == null) return;

    setState(() {
      widget.memory.paths
        ..clear()
        ..addAll(updatedMemory.paths);
      widget.memory.notes
        ..clear()
        ..addAll(updatedMemory.notes);
    });

    await _buildPreviewList();
  }

  @override
  void dispose() {
    noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Main detail view with notes and images.
    return PieCanvas(
      theme: const PieTheme(
        tooltipTextStyle: TextStyle(color: Colors.white),
        angleOffset: -100,
        spacing: 8,
        radius: 70,
        regularPressShowsMenu: false,
        longPressShowsMenu: true,
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              title: Text(
                widget.memory.title,
                style: const TextStyle(color: Colors.white),
              ),
              leading: BackButton(color: Colors.white),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: FloatingActionButton(
                    heroTag: 'note',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      showAppFluidDialog<void>(
                        context: context,
                        alignment: Alignment.bottomLeft,
                        builder: (_) => AppFluidDialog(
                          title: AppStrings.addNote,
                          content: TextField(
                            controller: noteController,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: AppStrings.addNoteText,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppStrings.cancel, style: TextStyle(color: Colors.grey),),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await addNote();
                              },
                              child: Text(AppStrings.add, style: TextStyle(color: Colors.green),),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.note_add, color: Colors.black),
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'image',
                  backgroundColor: Colors.white,
                  onPressed: pickAndUploadImages,
                  child:
                      const Icon(Icons.add_photo_alternate, color: Colors.black),
                ),
              ],
            ),
            body: CustomRefreshIndicator(
              builder: (context, child, controller) {
                final value = controller.value.clamp(0.0, 1.0);
                final indicatorLoading = controller.state.isLoading;
                final topInset = MediaQuery.of(context).padding.top;
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    child,
                    Positioned(
                      top: topInset + 8,
                      child: Opacity(
                        opacity: indicatorLoading ? 1.0 : value,
                        child: Transform.scale(
                          scale:
                              indicatorLoading ? 1.0 : (0.5 + (0.5 * value)),
                          child: Container(
                            width: 70,
                            height: 70,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              onRefresh: _refreshDetail,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  ...widget.memory.notes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "• $note",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dataList.asMap().entries.map((entry) {
                    final i = entry.key;
                    final preview = entry.value;
                    return Center(
                      child: PieMenu(
                        actions: [
                          PieAction(
                            tooltip: Text(""),
                            onSelect: () async {
                              final imageUrl = preview.image?.url ?? '';
                              final imageName =
                                  Uri.parse(imageUrl).pathSegments.last;

                              final updatedMemory = await deleteImage(
                                context,
                                widget.memory.id,
                                imageName,
                                widget.memory.notes,
                              );

                              if (!mounted) return;
                              if (updatedMemory == null) return;

                              setState(() {
                                widget.memory.paths
                                  ..clear()
                                  ..addAll(updatedMemory.paths);
                                widget.memory.notes
                                  ..clear()
                                  ..addAll(updatedMemory.notes);
                              });

                              await _buildPreviewList();
                            },
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        child: GestureDetector(
                          onTap: () async {
                            final result = await context.pushTransparentRoute(
                              ImagePreviewPage(
                                data: dataList,
                                initialIndex: i,
                                memoryId: widget.memory.id,
                                notes: widget.memory.notes,
                              ),
                            );

                            if (!mounted) return;
                            if (result is MemoryModel) {
                              setState(() {
                                widget.memory.paths
                                  ..clear()
                                  ..addAll(result.paths);
                                widget.memory.notes
                                  ..clear()
                                  ..addAll(result.notes);
                              });

                              await _buildPreviewList();
                            }
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                width: 280,
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(color: Colors.white, width: 10),
                                    left: BorderSide(color: Colors.white, width: 10),
                                    right: BorderSide(color: Colors.white, width: 10),
                                    bottom: BorderSide(color: Colors.white, width: 45),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: preview.image!.url!,
                                  httpHeaders: {
                                    "Authorization": "Bearer ${Login.userToken}",
                                    "Accept": "application/json",
                                  },
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const SizedBox(
                                    height: 200,
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 100),
                ],
              ),
            ),
        ),
        if (isUploading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
