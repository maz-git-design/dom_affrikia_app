import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key, this.color, this.alignement});

  final Color? color;
  final Alignment? alignement;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignement ?? Alignment.center,
      child: SpinKitThreeBounce(
        color: widget.color ?? Theme.of(context).colorScheme.primary,
        size: 30.0.r,
        controller: _animationController,
      ),
    );
  }
}
