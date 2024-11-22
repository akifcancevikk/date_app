// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'dart:io';
import 'package:date_app/api/service.dart';
import 'package:date_app/global/lists.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/screen_helper.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:date_app/views/main_page.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
        errorMessage(context ,'Error during initState: $e');
    }
  });
}


Future<void> loadAssets() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        imageFiles = result.paths.map((path) => File(path!)).toList();
      });
    } else {
      warningMessage(context, "Kullanıcı resim seçmedi.");
    }
  } catch (e) {
    errorMessage(context ,"Hata: $e");
  }
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
    final uniqueFileName = generateUniqueFileName(placeName, imageFile);

    var request = http.MultipartRequest(
        'POST', Uri.parse('${Url.baseUrl}uploadImage'));

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: uniqueFileName, // Dosya ismi burada kullanılıyor
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      return uniqueFileName;
    } else {
      errorMessage(context,'Resim yüklenemedi. Durum kodu: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () {
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
              backgroundColor: Color.fromRGBO(200, 162, 200, 1),
              tooltip: "Not Ekle",
              heroTag: 2,
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return Platform.isIOS
                    ? CupertinoAlertDialog(
                        title: Text("Not Ekle"),
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
                                  labelText: 'Not Girin',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Notu giriniz',
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
                        ),
                        actions: [
                        CupertinoDialogAction(
                          child: Text(
                            "İptal",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          onPressed: () {
                            noteController.text = "";
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text(
                            "Ekle",
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold),
                          ),
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
                                title: Text("Not Ekle"),
                                content: Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) {
                                        PlaceDetail.noteText = value;
                                      },
                                      controller: noteController,
                                      decoration: InputDecoration(
                                        labelText: 'Not Girin',
                                        labelStyle: TextStyle(color: Colors.grey),
                                        hintText: 'Notu giriniz',
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
                                        "İptal",
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
                                      "Ekle",
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
              child: Icon(Icons.note_add_outlined, color: Colors.white,),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color.fromRGBO(200, 162, 200, 1),
            heroTag: 1,
            tooltip: "Resim Ekle",
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Container(
                    height: ScreenHelper.screenHeightPercentage(context, 70),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if(imageFiles.isEmpty)
                          ElevatedButton(
                            onPressed: loadAssets,
                            child: Text("Galeriden Resim Seç")),
                          SizedBox(height: 20),
                          if(imageFiles.isNotEmpty)
                          ElevatedButton(
                            onPressed: () async {
                              for (var imageFile in imageFiles) {
                                String? uploadedFileName = await uploadImage(imageFile);
                                if (uploadedFileName != null) {
                                  PlaceDetail.imagePath = uploadedFileName;
                                  PlaceDetail.placeId = GlobalLists.placesDetail[0].placeId;
                                  await addImagePath(context);
                                  await getPlaces();
                                  imageFiles = [];
                                  setState(() {});
                                } else {
                                  errorMessage(context, 'Resim yükleme başarısız.');
                                }
                              }
                              await getPlaceDetails();
                              Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => PlaceDetailPage()), );
                            },
                            child: Text("Resimleri Yükle"),
                          ),
                          SizedBox(height: 20),
                          imageFiles.isNotEmpty
                          ? Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                itemCount: imageFiles.length,
                                itemBuilder: (context, index) {
                                  return Image.file(
                                    imageFiles[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            )
                          : Text("Lütfen bir resim seçin."),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Icon(Icons.add_photo_alternate_outlined, color: Colors.white,),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final detail = GlobalLists.placesDetail[0];
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: detail.notes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "• ${detail.notes[index]}",
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8,),
                SingleChildScrollView(   
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dataList.map<Widget>((preview) {
                    final i = dataList.indexOf(preview);
                    return SizedBox(
                      width: ScreenHelper.screenWidth(context),
                      height: 240,
                      child: PreviewThumbnail(
                        data: dataList[i],
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
                                      top: MediaQuery.of(context).padding.top + 16,
                                      right: 32),
                                  child: InkWell(
                                    onTap: () {
                                      debugPrint('tap tip $currentIndex');
                                    },
                                    child: Text(
                                      '${currentIndex + 1}/${dataList.length}',
                                      style:
                                          TextStyle(color: Colors.white.withAlpha(180)),
                                    ),
                                  ),
                                ),
                              );
                            },
                            onLongPressHandler: (con, url) =>
                                debugPrint(preview.image?.url),
                            onPageChanged: (i) async {
                              debugPrint('onPageChanged $i');
                            },
                          );
                        },
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
    );
  }
}
