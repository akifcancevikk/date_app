// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/models/memory_model.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_preview/preview_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:date_app/views/image_preview_page.dart';


class DetailPage extends StatefulWidget {
  final MemoryModel memory;

  const DetailPage({super.key, required this.memory});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isUploading = false;
  final TextEditingController noteController = TextEditingController();

  final List<PreviewData> dataList = [];

  static const String baseImageUrl =
      'https://explore-log.emrecanful.me/api/memories';

  @override
  void initState() {
    super.initState();
    _buildPreviewList();
  }

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

      final imageUrl =
          '$baseImageUrl/${widget.memory.id}/image/$imageName';

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

    setState(() {
      dataList
        ..clear()
        ..addAll(temp);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(AppStrings.addNote),
                        content: TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                            hintText: AppStrings.addNoteText,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: Text(AppStrings.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await addNote();
                            },
                            child: Text(AppStrings.add),
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
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Column(
                  children: dataList.map((preview) {
                    final i = dataList.indexOf(preview);
                    return Dismissible(
                      key: ValueKey(preview.image?.url ?? i),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) async {
                        final imageUrl = preview.image?.url ?? '';
                        final imageName = Uri.parse(imageUrl).pathSegments.last;

                        final updatedMemory = await deleteImage(
                          context,
                          widget.memory.id,
                          imageName,
                          widget.memory.notes,
                        );

                        if (!mounted) return false;

                        if (updatedMemory == null) return false;

                        setState(() {
                          widget.memory.paths
                            ..clear()
                            ..addAll(updatedMemory.paths);
                          widget.memory.notes
                            ..clear()
                            ..addAll(updatedMemory.notes);
                        });

                        await _buildPreviewList();

                        return true;
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red.shade700,
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
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
                              placeholder: (_, __) =>
                                  const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
    );
  }
}
