// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, sort_child_properties_last
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:date_app/api/service.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/helper/date_format.dart';
import 'package:date_app/helper/screen_helper.dart';
import 'package:date_app/helper/url_helper.dart';
import 'package:date_app/provider/provider.dart';
import 'package:date_app/views/detail_page.dart';
import 'package:date_app/widgets/dialogs/app_fluid_dialog.dart';
import 'package:date_app/widgets/global_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _memoryNameController = TextEditingController();
  final TextEditingController _memoryNameUpdateController = TextEditingController();
  final IndicatorController _refreshController = IndicatorController();
  final ScrollController _scrollController = ScrollController();
  bool isMoreLoading = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start initial fetch and connect infinite scroll listener.
    isLoading = true;
    _scrollController.addListener(_scrollListener);
    _initializeAsyncData();
  }

  void _scrollListener() {
    // Trigger pagination when approaching the bottom.
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<MemoryProvider>();
      if (provider.hasNextPage && !isMoreLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    // Load the next page of results.
    setState(() => isMoreLoading = true);
    await fetchMemories(context);
    setState(() => isMoreLoading = false);
  }

  Future<void> _initializeAsyncData() async {
    // Load the first page and end skeleton state.
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
    // Main list view for all memories.
    final memoriesProvider = context.watch<MemoryProvider>();
    final memories = memoriesProvider.memories;

    return PieCanvas(
      theme: const PieTheme(
        tooltipTextStyle: TextStyle(color: Colors.white),
        customAngle: -200,
        spacing: 8,
        radius: 70,
        regularPressShowsMenu: false,
        longPressShowsMenu: true,
      ),
      child: ScrollsToTop(
        onScrollsToTop: (event) {
          return _scrollController.animateTo(
            event.to,
            duration: event.duration,
            curve: event.curve,
          );
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: "exit",
                backgroundColor: Colors.red,
                child: Icon(Icons.exit_to_app),
                onPressed: () {
                  showAppFluidDialog<void>(
                    context: context,
                    alignment: Alignment.bottomRight,
                    builder: (context) {
                      return AppFluidDialog(
                        title: AppStrings.exit,
                        content: Text(AppStrings.sureExit),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppStrings.cancel, style: TextStyle(color: Colors.grey),),
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
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "add",
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  showAppFluidDialog<void>(
                    context: context,
                    alignment: Alignment.bottomRight,
                    builder: (context) {
                      return AppFluidDialog(
                        title: AppStrings.addMemory,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _memoryNameController,
                              decoration: InputDecoration(
                                labelText: AppStrings.memoryName,
                              ),
                              minLines: 1,
                              maxLines: 2,
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
                            child: Text(AppStrings.cancel, style: TextStyle(color: Colors.grey),),
                          ),
                          TextButton(
                            onPressed: () async {
                              await create(context);
                              _memoryNameController.clear();
                              Navigator.pop(context);
                              await fetchMemories(context);
                            },
                            child: Text(AppStrings.add, style: TextStyle(color: Colors.green),),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
        ),

          body: globalAppBar(
            context, 
            false,
            action: SizedBox(),
            CustomRefreshIndicator(
              controller: _refreshController,
              onRefresh: () async {
                setState(() => isLoading = true);
                await fetchMemories(context, isRefresh: true);
                if (!mounted) return;
                  setState(() => isLoading = false);
                },
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                children: [
                                  const SizedBox(
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
                child: Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()
                    ),
                    controller: _scrollController,
                    itemCount: memories.length + (isMoreLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      final memory = memories[index];
              
                      // Swipe actions for update (left) and delete (right).
                      return Dismissible(
                        key: ValueKey(memory.id),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            return await showAppFluidDialog<bool>(
                                  context: context,
                                  alignment: Alignment.centerRight,
                                  builder: (context) {
                                    return AppFluidDialog(
                                      title: AppStrings.deleteRecord,
                                      content: Text(AppStrings.sureDeletePlace),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(AppStrings.no, style: TextStyle(color: Colors.grey),),
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
                                    );
                                  },
                                ) ??
                                false;
                          } else {
                            MemoryUpdate.memoryId = memory.id;
                            MemoryUpdate.memoryName = memory.title;
                            MemoryUpdate.memoryRating = memory.rating;
                            _memoryNameUpdateController.text = memory.title;
                            showAppFluidDialog<void>(
                              context: context,
                              alignment: Alignment.centerLeft,
                              builder: (context) {
                                return AppFluidDialog(
                                  title: AppStrings.update,
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
                                      child: Text(AppStrings.cancel, style: TextStyle(color: Colors.grey),),
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
                                );
                              },
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
                        child: PieMenu(
                          actions: [
                            PieAction(
                              tooltip: Text(""),
                              onSelect: () {
                                MemoryUpdate.memoryId = memory.id;
                                MemoryUpdate.memoryName = memory.title;
                                MemoryUpdate.memoryRating = memory.rating;
                                _memoryNameUpdateController.text = memory.title;
                                showAppFluidDialog<void>(
                                  context: context,
                                  alignment: Alignment.centerLeft,
                                  builder: (context) {
                                    return AppFluidDialog(
                                      title: AppStrings.update,
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
                                            style: TextStyle(
                                                color: Colors.green),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.update,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            PieAction(
                              tooltip: Text(""),
                              onSelect: () async {
                                final confirm = await showAppFluidDialog<bool>(
                                      context: context,
                                      alignment: Alignment.centerRight,
                                      builder: (context) {
                                        return AppFluidDialog(
                                          title: AppStrings.deleteRecord,
                                          content: Text(AppStrings.sureDeletePlace),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, false),
                                              child: Text(AppStrings.no),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await deleteMemory(
                                                    context, memory.id);
                                                Navigator.pop(
                                                    context, true);
                                              },
                                              child: Text(
                                                AppStrings.yes,
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ) ??
                                    false;
                                if (!confirm) return;
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
                                    SizedBox(
                                      width: 280,
                                      child: Text(
                                        memory.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                                              color: Colors.white,
                                              width: 10),
                                          left: BorderSide(
                                              color: Colors.white,
                                              width: 10),
                                          right: BorderSide(
                                              color: Colors.white,
                                              width: 10),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  memory.paths.isEmpty
                                                      ? "https://mobiledocs.aktekweb.com/places/bos.jpg"
                                                      : "${Url.memories}memories/${memory.id}/image/${memory.paths.first}",
                                              httpHeaders: {
                                                "Authorization":
                                                    "Bearer ${Login.userToken}",
                                                "Accept":
                                                    "application/json",
                                              },
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) =>
                                                  const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              errorWidget:
                                                  (_, __, ___) =>
                                                      const Icon(
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
                                                EdgeInsets.symmetric(
                                                    horizontal: 8),
                                            child: Text(
                                              memory.title,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 50,)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ),
          )
          
        ),
      ),
    );
  }
}
