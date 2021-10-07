import 'dart:ui';

class Page {
  Page({
    this.key,
    required this.index,
    required this.height,
    required this.color,
  });

  int? key;
  int index;
  double height;
  Color color;
}
