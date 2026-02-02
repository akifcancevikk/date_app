// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/lists.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/screen_helper.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:date_app/views/main_page.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:image_preview/preview.dart';
import 'package:image_preview/preview_data.dart';
import 'package:path_provider/path_provider.dart';


class PlaceDetailPage extends StatefulWidget {
  const PlaceDetailPage({super.key});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  bool isUploading = false;
  final TextEditingController noteController = TextEditingController();

  List<File> imageFiles = [];
  final List<PreviewData> dataList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        String path = '';
        if (!kIsWeb) {
          if (Platform.isAndroid) {
            path = ((await getExternalCacheDirectories())?[0].path ?? '');
          } else {
            path = (await getTemporaryDirectory()).path;
          }
        }

        final temp = GlobalLists.placesDetail[0].images.asMap().entries.map((entry) {
          final index = entry.key;
          final imageUrl = '${Url.imgUrl}${Uri.encodeComponent(entry.value)}';
          final fileName = Uri.parse(imageUrl).pathSegments.last;
          final localPath = '$path/$fileName';

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
          dataList.addAll(temp);
        });
      } catch (e) {
        errorMessage(context, 'Error during initState: $e');
      }
    });
  }

  Future<void> pickAndUploadImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result == null || result.paths.isEmpty) {
        warningMessage(context, AppStrings.noneSelected);
        return;
      }

      setState(() {
        isUploading = true;
      });

      final files = result.paths.map((p) => File(p!)).toList();

      for (var imageFile in files) {
        String? uploadedFileName = await uploadImage(imageFile);

        if (uploadedFileName != null) {
          PlaceDetail.imagePath = uploadedFileName;
          PlaceDetail.placeId = GlobalLists.placesDetail[0].placeId;
          await addImagePath(context);
        } else {
          errorMessage(context, AppStrings.uploadFail);
        }
      }

      // 🔥 KRİTİK: yeni datayı çek
      await getPlaceDetails();

      // 🔥 dataList'i yeniden oluştur
      rebuildPreviewList();

      setState(() {
        isUploading = false;
      });

      // ✅ SADECE 1 KERE
      successMessage(context, AppStrings.imageAdded);

    } catch (e) {
      setState(() {
        isUploading = false;
      });
      errorMessage(context, '${AppStrings.error}: $e');
    }
  }

  void rebuildPreviewList() async {
    String path = '';
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        path = ((await getExternalCacheDirectories())?[0].path ?? '');
      } else {
        path = (await getTemporaryDirectory()).path;
      }
    }

    final temp = GlobalLists.placesDetail[0].images.asMap().entries.map((entry) {
      final index = entry.key;
      final imageUrl = '${Url.imgUrl}${Uri.encodeComponent(entry.value)}';
      final fileName = Uri.parse(imageUrl).pathSegments.last;
      final localPath = '$path/$fileName';

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

  String generateRandomNumber() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  String generateUniqueFileName(String placeName, File imageFile) {
    String randomNumber = generateRandomNumber();
    String fileExtension = imageFile.path.split('.').last;
    String fileName = '${placeName}_$randomNumber.$fileExtension';
    return fileName;
  }

  Future<String?> uploadImage(File imageFile) async {
    final placeName = GlobalLists.placesDetail[0].placeName;
    final userName = GlobalLists.placesDetail[0].userName;
    final uniqueFileName = generateUniqueFileName(placeName, imageFile);

    var request = http.MultipartRequest(
        'POST', Uri.parse('${Url.baseUrl}uploadImage'));

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: uniqueFileName,
    ));

    request.fields['UserName'] = userName;

    var response = await request.send();
    if (response.statusCode == 200) {
      return uniqueFileName;
    } else {
      final responseBody = await response.stream.bytesToString();
      debugPrint('Resim yüklenemedi. Durum kodu : ${response.statusCode}');
      debugPrint('Hata detayları: $responseBody');
      return null;
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
            surfaceTintColor: Colors.black,
            centerTitle: true,
            title: Text(
              GlobalLists.placesDetail[0].placeName,
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              onPressed: () async {
                await getPlaces();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: Icon(Icons.arrow_back_rounded),
              color: Colors.white,
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  tooltip: AppStrings.addNote,
                  heroTag: 2,
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return Platform.isIOS
                        ? CupertinoAlertDialog(
                            title: Text(AppStrings.addNote),
                            content: Material(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      PlaceDetail.noteText = value;
                                    },
                                    controller: noteController,
                                    decoration: InputDecoration(
                                      labelText: AppStrings.addNoteText,
                                      labelStyle: TextStyle(color: Colors.grey),
                                      hintText: AppStrings.addNoteText,
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                            CupertinoDialogAction(
                              child: Text(AppStrings.cancel,style: TextStyle(color: Colors.grey.shade600)),
                              onPressed: () {
                                noteController.text = "";
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(AppStrings.add, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                              onPressed: () async {
                                PlaceDetail.placeId =
                                GlobalLists.placesDetail[0].placeId;
                                PlaceDetail.orderIndex =
                                GlobalLists.placesDetail[0].images.length + 1;
                                await addNote(context);
                                noteController.text = "";
                                Navigator.pop(context);
                                await getPlaceDetails();
                                setState(() {});
                              },
                            ),
                          ],
                        )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(AppStrings.addNote),
                              content: Column(
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      PlaceDetail.noteText = value;
                                    },
                                    controller: noteController,
                                    decoration: InputDecoration(
                                      labelText: AppStrings.addNoteText,
                                      labelStyle: TextStyle(color: Colors.grey),
                                      hintText: AppStrings.addNoteText,
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      noteController.text = "";
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      AppStrings.cancel,
                                      style: TextStyle(color: Colors.grey),
                                    )),
                                TextButton(
                                  onPressed: () async {
                                    PlaceDetail.placeId =
                                    GlobalLists.placesDetail[0].placeId;
                                    PlaceDetail.orderIndex =
                                    GlobalLists.placesDetail[0].notes.length + 1;
                                    await addNote(context);
                                    noteController.text = "";
                                    Navigator.pop(context);
                                    await getPlaceDetails();
                                    setState(() {});
                                  },
                                  child: Text(
                                    AppStrings.add,
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(Icons.note_add_outlined, color: Colors.black,),
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: 1,
                tooltip: AppStrings.addImage,
                onPressed: pickAndUploadImages,
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          body:  LayoutBuilder(
            builder: (context, constraints) {
              final detail = GlobalLists.placesDetail[0];
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: detail.notes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8,8,16,0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  detail.notes[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dataList.map<Widget>((preview) {
                          final i = dataList.indexOf(preview);
                          return SizedBox(
                            height: ScreenHelper.screenHeightPercentage(context, 50),
                            width: ScreenHelper.screenWidthPercentage(context, 70),
                            child: GestureDetector(
                              onTap: () {
                                openPreviewPages(
                                  Navigator.of(context),
                                  data: dataList,
                                  index: i,
                                  indicator: kIsWeb || Platform.isMacOS ||
                                      Platform.isWindows ||
                                      Platform.isLinux,
                                  tipWidget: (currentIndex) {
                                    return Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: MediaQuery.of(context).padding.top + 50,
                                          right: 32
                                        ),
                                        child: Text(
                                          '${currentIndex + 1}/${dataList.length}',
                                          style: TextStyle(color: Colors.white.withAlpha(180)),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.white, width: 10),
                                      left: BorderSide(color: Colors.white, width: 10),
                                      right: BorderSide(color: Colors.white, width: 10),
                                      bottom: BorderSide(color: Colors.white, width: 50),
                                    ),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: preview.image?.url ?? '',
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),   
        ),
        if (isUploading)
        Container(
          color: Colors.black.withValues(alpha: 0.6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}