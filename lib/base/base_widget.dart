import 'package:flutter/material.dart';

class BaseWidget extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? bodyAppBar;
  final bool canPop;

  const BaseWidget({
    super.key,
    required this.body,
    this.bodyAppBar,
    this.canPop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: bodyAppBar,
      body: body,
    );
  }
}
