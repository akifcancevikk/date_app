import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_appbar/flutter_appbar.dart';

SafeArea globalAppBar(
  BuildContext context,
  bool isPop,
  Widget child, {
  dynamic secondaryAppBar,
  bool showSearch = false,
  VoidCallback? onSearchTap,
  dynamic action
}) {
  return SafeArea(
    bottom: false,
    child: AppBarConnection(
      appBars: [
        AppBar(
          maxExtent: 60,
          behavior: const MaterialAppBarBehavior(floating: true),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isPop ?
              Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                )
                : const SizedBox(),

                action
            ],
          ),
        ),
        if (secondaryAppBar != null) secondaryAppBar,
      ],
      child: child,
    ),
  );
}
