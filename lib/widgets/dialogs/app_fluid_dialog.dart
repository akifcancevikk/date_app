import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';

Future<T?> showAppFluidDialog<T>({
  required BuildContext context,
  required Alignment alignment,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (_) => FluidDialog(
      defaultDecoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      rootPage: FluidDialogPage(
        alignment: alignment,
        builder: builder,
      ),
    ),
  );
}

class AppFluidDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget> actions;
  final Color backgroundColor;

  const AppFluidDialog({
    super.key,
    this.title,
    required this.content,
    required this.actions,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                content,
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
