// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, sort_child_properties_last
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/date_format.dart';
import 'package:date_app/helper/screen_helper.dart';
import 'package:date_app/provider/provider.dart';
import 'package:date_app/views/detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _memoryNameController = TextEditingController();
  final TextEditingController _memoryNameUpdateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isMoreLoading = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _scrollController.addListener(_scrollListener);
    _initializeAsyncData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<MemoryProvider>();
      if (provider.hasNextPage && !isMoreLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => isMoreLoading = true);
    await fetchMemories(context);
    setState(() => isMoreLoading = false);
  }

  Future<void> _initializeAsyncData() async {
    await fetchMemories(context);
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _memoryNameController.dispose();
    _memoryNameUpdateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoriesProvider = context.watch<MemoryProvider>();
    final memories = memoriesProvider.places;

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "exit",
            backgroundColor: Colors.red,
            child: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(AppStrings.exit),
                  content: Text(AppStrings.sureExit),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await logout(context);
                      },
                      child: Text(
                        AppStrings.exit,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "add",
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(AppStrings.addPlace),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _memoryNameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.placeName,
                        ),
                        onChanged: (v) => Memory.memoryName = v,
                      ),
                      SizedBox(height: 20),
                      RatingBar.builder(
                        initialRating: 1,
                        minRating: 1,
                        itemCount: 5,
                        itemBuilder: (_, __) =>
                            Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (r) =>
                            Memory.memoryRating = r.toInt(),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _memoryNameController.clear();
                        Navigator.pop(context);
                      },
                      child: Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () async {
                        await create(context);
                        _memoryNameController.clear();
                        Navigator.pop(context);
                        await fetchMemories(context);
                      },
                      child: Text(AppStrings.add),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: 
      Skeletonizer(
        enabled: isLoading,
        child: ListView.builder(
            controller: _scrollController,
            itemCount: memories.length + (isMoreLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == memories.length) {
                return Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final memory = memories[index];
        
              return Dismissible(
                key: ValueKey(memory.id),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    return await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(AppStrings.deletePlace),
                        content: Text(AppStrings.sureDeletePlace),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: Text(AppStrings.no),
                          ),
                          TextButton(
                            onPressed: () async {
                              await deleteMemory(context, memory.id);
                                Navigator.pop(context, true);
                            },
                            child: Text(
                              AppStrings.yes,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    MemoryUpdate.memoryId = memory.id;
                    MemoryUpdate.memoryName = memory.title;
                    MemoryUpdate.memoryRating = memory.rating;
                    _memoryNameUpdateController.text = memory.title;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(AppStrings.update),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller:
                                  _memoryNameUpdateController,
                              onChanged: (v) =>
                                  MemoryUpdate.memoryName = v,
                            ),
                            SizedBox(height: 20),
                            RatingBar.builder(
                              initialRating:
                                  memory.rating.toDouble(),
                              itemCount: 5,
                              itemBuilder: (_, __) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (r) =>
                                  MemoryUpdate.memoryRating =
                                      r.toInt(),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: Text(AppStrings.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              await updateMemory(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppStrings.update,
                              style:
                                  TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    );
                    return false;
                  }
                },
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.update, color: Colors.white),
                ),
                secondaryBackground: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => DetailPage(memory: memory,),));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: ScreenHelper.screenWidth(context),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            GlobalDateFormat.formatDate(
                                memory.createdAt.toString()),
                            style: TextStyle(color: Colors.white),
                          ),
                          RatingBar.builder(
                            itemSize: 20,
                            initialRating:
                                memory.rating.toDouble(),
                            allowHalfRating: false,
                            itemCount: 5,
                            itemBuilder: (_, __) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (_) {},
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 280,
                            height: 400,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: Colors.white, width: 10),
                                left: BorderSide(
                                    color: Colors.white, width: 10),
                                right: BorderSide(
                                    color: Colors.white, width: 10),
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: CachedNetworkImage(
                                    imageUrl: memory.paths.isEmpty
                                        ? "https://mobiledocs.aktekweb.com/places/bos.jpg"
                                        : "https://explore-log.emrecanful.me/api/memories/${memory.id}/image/${memory.paths.first}",
                                    httpHeaders: {
                                      "Authorization": "Bearer ${Login.userToken}",
                                      "Accept": "application/json",
                                    },
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  )
                                ),
                                Container(
                                  height: 40,
                                  color: Colors.white,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    memory.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}
