// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, sort_child_properties_last

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/global/lists.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/date_format.dart';
import 'package:date_app/helper/screen_helper.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:date_app/views/login.dart';
import 'package:date_app/views/place_detail.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _placeNameUpdateController = TextEditingController();

    Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('password');
    Navigator.pushAndRemoveUntil(context,  MaterialPageRoute(builder: (context) => LoginPage()),  (Route<dynamic> route) => false);
  }
  @override 
  void dispose() { 
    _placeNameController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: SizedBox(),
          toolbarHeight: 30,
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: 3,
              backgroundColor: Colors.red,
              onPressed: null,
              child: IconButton(onPressed: () {
                showDialog(
                    context: context, 
                    barrierDismissible: true,
                    builder: (context) {
                    return 
                    Platform.isIOS
                    ?CupertinoAlertDialog(
                      title: Text("Çıkış Yap"),
                      content: Text("Çıkış yapmak istediğinize emin misiniz?"),
                      actions: [
                        CupertinoDialogAction(
                          child: Text("İptal", style: TextStyle(color: Colors.grey.shade600),),
                          onPressed: () => Navigator.pop(context),
                        ),
                        CupertinoDialogAction(
                          child: Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                          onPressed: () async => logout(context),
                        ),
                      ],
                    )
                    : AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text("Çıkış Yap"),
                      content: Text("Çıkış yapmak istediğinize emin misiniz?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text("İptal", style: TextStyle(color: Colors.grey),)),
                        TextButton(onPressed: () async => logout(context), child: Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),))
                      ],
                    );
                  },
                );
              }, icon: Icon(Icons.exit_to_app, color: Colors.white,)),
            ),
            SizedBox(height: 5,),
            FloatingActionButton(
              heroTag: 5,
              onPressed: () {
              showDialog(
                context: context, 
                barrierDismissible: true,
                builder: (context) {
                return  Platform.isIOS
                ? CupertinoAlertDialog( 
                  title: Text("Yer Ekle"), 
                  content: Material( 
                        color: Colors.transparent, 
                        child: Column( 
                          children: 
                          [ 
                            TextField(
                              onChanged: (value) {
                                Place.placeName = value;
                              },
                              controller: _placeNameController,
                              decoration: InputDecoration(
                                labelText: 'Yer İsmi',
                                labelStyle: TextStyle(color: Colors.grey),
                                hintText: 'Yer ismini giriniz',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Pasif durumdaki sınır rengi
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Focus durumundaki sınır rengi
                                ),
                              ),
                            ), 
                            SizedBox(height: 20), 
                            RatingBar.builder(
                              itemSize: 35, 
                              glow: true, 
                              initialRating: Place.placeRating!.toDouble(), 
                              minRating: 1, 
                              direction: Axis.horizontal, 
                              allowHalfRating: false, 
                              itemCount: 5, 
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0), 
                              itemBuilder: (context, _) => Icon( 
                                Icons.star, 
                                color: Colors.amber), 
                                onRatingUpdate: (rating) { 
                                  Place.placeRating = rating.toInt();
                                }, 
                              ), 
                          ], 
                        ), 
                      ), 
                  actions: [ 
                  CupertinoDialogAction( 
                    child: Text( "İptal", style: TextStyle(color: Colors.grey.shade600), ), 
                    onPressed: () {
                      _placeNameController.text = "";
                      Navigator.pop(context);
                    } 
                  ), 
                    CupertinoDialogAction( 
                      child: Text( "Ekle", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold), ), 
                      onPressed: () async{
                        await addPlace(context);
                        _placeNameController.text = "";
                        Navigator.pop(context);
                        await getPlaces();
                        setState(() {
                          
                        });
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
                         title: Text("Yer Ekle"),
                          content: Column(
                          children: [
                            TextField(
                              onChanged: (value) {
                                Place.placeName = value;
                              },
                              controller: _placeNameController,
                              decoration: InputDecoration(
                                labelText: 'Yer İsmi',
                                labelStyle: TextStyle(color: Colors.grey),
                                hintText: 'Yer ismini giriniz',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Pasif durumdaki sınır rengi
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Focus durumundaki sınır rengi
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            RatingBar.builder(
                              itemSize: 35, 
                              glow: true,
                              initialRating: 1,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                Place.placeRating = rating.toInt();
                              },
                            ),
                          ],
                         ),
                         actions: [
                           TextButton(onPressed: () {
                          _placeNameController.text = "";
                          Navigator.pop(context);
                        } , child: Text("İptal", style: TextStyle(color: Colors.grey),)),
                           TextButton(
                            onPressed: () async{
                              await addPlace(context);
                              _placeNameController.text = "";
                              Navigator.pop(context);
                              await getPlaces();
                              setState(() {
                                
                              });
                             },
                            child: Text("Ekle", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),)
                          )
                         ],
                       ),
                     ],
                );
                 },
               );
             },
             child: Icon(Icons.add, size: 32,),
             backgroundColor: Colors.white,
            ),
          ],
        ),
        body: 
        GlobalLists.places[0].placeId != 0
        ?ResponsiveGridList(
        listViewBuilderOptions: ListViewBuilderOptions(
          physics: BouncingScrollPhysics(),
        ),
        horizontalGridMargin: 8,
        horizontalGridSpacing: 8,
        verticalGridSpacing: 8,
        verticalGridMargin: 8,
        minItemWidth: 350,
        children: List.generate(
               GlobalLists.places.length,
               (index){
                 final places = GlobalLists.places[index];
                 return Dismissible(
                   key: ValueKey(places.placeId),
                   direction: DismissDirection.horizontal,
                   confirmDismiss: (direction) async {
                   if (direction == DismissDirection.endToStart) {
                     return await showDialog(
                    context: context,
                    builder: (context) => Platform.isIOS
                    ? CupertinoAlertDialog(
                        title: Text("Kaydı Sil"),
                        content: Text("Kaydı silmek istediğinize emin misiniz?"),
                        actions: [
                        CupertinoDialogAction(
                          child: Text(
                                  "Hayır",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text(
                            "Evet",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    )
                    : AlertDialog(
                        title: Text("Kaydı Sil"),
                        content: Text("Kaydı silmek istediğinize emin misiniz?"),
                        actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "Hayır",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            "Evet",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                   } else if (direction == DismissDirection.startToEnd) {
                     PlaceUpdate.placeId = places.placeId.toString();
                     PlaceUpdate.placeRating = places.rating;
                     PlaceUpdate.placeName = places.placeName;
                     _placeNameUpdateController.text = places.placeName;
                     showDialog(
                    context: context, 
                    barrierDismissible: true,
                    builder: (context) {
                    return  Platform.isIOS
                    ? CupertinoAlertDialog( 
                        title: Text("Güncelle"), 
                        content: Material( 
                          color: Colors.transparent, 
                          child: Column( 
                            children: 
                            [ 
                              TextField(
                                onChanged: (value) {
                                  PlaceUpdate.placeName = value;
                                },
                                controller: _placeNameUpdateController,
                                decoration: InputDecoration(
                                  labelText: 'Yer İsmi',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Yer ismini giriniz',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ), 
                              SizedBox(height: 20), 
                              RatingBar.builder(
                                itemSize: 35, 
                                glow: true, 
                                initialRating: PlaceUpdate.placeRating!.toDouble(), 
                                minRating: 1, 
                                direction: Axis.horizontal, 
                                allowHalfRating: false, 
                                itemCount: 5, 
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0), 
                                itemBuilder: (context, _) => Icon( 
                                  Icons.star, 
                                  color: Colors.amber), 
                                  onRatingUpdate: (rating) { 
                                    PlaceUpdate.placeRating = rating.toInt();
                                  }, 
                                ), 
                            ], 
                          ), 
                        ), 
                        actions: [ 
                          CupertinoDialogAction( 
                            child: Text( "İptal", style: TextStyle(color: Colors.grey.shade600), ), 
                            onPressed: () {
                              _placeNameController.text = "";
                              Navigator.pop(context);
                            } 
                          ), 
                          CupertinoDialogAction( 
                            child: Text( "Güncelle", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), ), 
                            onPressed: () async{
                              await updatePlace(context);
                              _placeNameUpdateController.text = "";
                              Navigator.pop(context);
                              await getPlaces();
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
                          title: Text("Güncelle"),
                            content: Column( 
                            children: 
                            [ 
                              TextField(
                                onChanged: (value) {
                                  PlaceUpdate.placeName = value;
                                },
                                controller: _placeNameUpdateController,
                                decoration: InputDecoration(
                                  labelText: 'Yer İsmi',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Yer ismini giriniz',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey), // Pasif durumdaki sınır rengi
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey), // Focus durumundaki sınır rengi
                                  ),
                                ),
                              ), 
                              SizedBox(height: 20), 
                              RatingBar.builder(
                                itemSize: 35, 
                                glow: true, 
                                initialRating: PlaceUpdate.placeRating!.toDouble(), 
                                minRating: 1, 
                                direction: Axis.horizontal, 
                                allowHalfRating: false, 
                                itemCount: 5, 
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0), 
                                itemBuilder: (context, _) => Icon( 
                                  Icons.star, 
                                  color: Colors.amber), 
                                  onRatingUpdate: (rating) { 
                                    PlaceUpdate.placeRating = rating.toInt();
                                  }, 
                                ), 
                            ], 
                          ),
                          actions: [
                            TextButton(onPressed: () {
                            _placeNameController.text = "";
                            Navigator.pop(context);
                          } , child: Text("İptal", style: TextStyle(color: Colors.grey),)),
                            TextButton(
                              onPressed: () async{
                                await updatePlace(context);
                                _placeNameUpdateController.text = "";
                                Navigator.pop(context);
                                await getPlaces();
                                setState(() {});
                              },
                              child: Text("Güncelle", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),)
                            )
                          ],
                        ),
                      ],
                    );
                  },
                );     
                     return false;
                   }
                   return false;
                 },
                 onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    DeletePlace.id = places.userId.toString();
                    DeletePlace.placeId = places.placeId.toString();
                    await deletePlace(context);
                    await getPlaces();
                    setState(() {});
                  }
              },
                 secondaryBackground: Container(
                color: Colors.transparent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete_forever_outlined, color: Colors.red, size: 34,),
              ),
                 background: Container(
                   color: Colors.transparent,
                   alignment: Alignment.centerLeft,
                   padding: EdgeInsets.symmetric(horizontal: 20),
                   child: Icon(Icons.update, color: Colors.green, size: 30,),
                 ),
                 child: GestureDetector(
                  onTap: () async {
                    Place.placeId = places.placeId.toString();
                    await getPlaceDetails();
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => PlaceDetailPage(),));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: ScreenHelper.screenWidth(context),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              places.placeName,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              GlobalDateFormat.formatDate(places.visitDate),
                              style: TextStyle(color: Colors.white),
                            ),
                            RatingBar.builder(
                              ignoreGestures: false,
                              itemSize: 20,
                              glow: true,
                              initialRating: places.rating.toDouble(),
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding: EdgeInsets.only(right: 10.0),
                              unratedColor: Colors.grey,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) async {
                                PlaceUpdate.placeRating = rating.toInt();
                                PlaceUpdate.placeName = places.placeName;
                                PlaceUpdate.placeId = places.placeId.toString();
                                await updatePlace(context);
                                await getPlaces();
                                successMessage(context, "Derece değiştirildi");
                                setState(() {});
                              },
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 240,
                              height: 320,
                              child: places.imagePath != ""
                              ? CachedNetworkImage(
                                imageUrl: "${Url.imgUrl}${places.imagePath}",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              )
                              : CachedNetworkImage(
                                imageUrl: "https://mobiledocs.aktekweb.com/places/bos.jpg",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              )
                            ),
                          ],
                      )
                    ),
                  ),
              ),
             );         
            }
          ),
        )
        :ListTile(
          title: Align(alignment: Alignment.topCenter ,child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text("Veri Bulunamadı", style: TextStyle(color: Colors.white, fontSize: ScreenHelper.screenWidth(context) < 500 ?16:20),),
          )),
        )
      ),
    );
  }
}