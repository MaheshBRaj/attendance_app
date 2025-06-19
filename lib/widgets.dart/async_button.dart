import 'package:flutter/material.dart';

class AsyncButton extends StatefulWidget {
  const AsyncButton({
    required this.child,
    required this.onPressed,
    super.key,
    this.size,
    this.customLoader,
  });
  final Widget child;
  final Function() onPressed;
  final double? size;
  final Widget? customLoader;
  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  final ValueNotifier<bool> _valueNotifier = ValueNotifier(false);

  Future<void> _onTap() async {
    _valueNotifier.value = true;
    await widget.onPressed();
    _valueNotifier.value = false;
  }

  @override
  Widget build(final BuildContext context) => ValueListenableBuilder(
    valueListenable: _valueNotifier,
    builder:
        (final context, final value, final child) => InkWell(
          onTap: value ? () {} : _onTap,
          child:
              value
                  ? widget.customLoader ?? CircularProgressIndicator()
                  : widget.child,
        ),
  );
}
