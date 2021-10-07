import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'page.dart' as pageClass;
import 'unboundedScrollView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Infinite Scroll'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _startIndex = 1000;
  int _endIndex = 1009;
  int _indexToJumpTo = 1000;

  List<pageClass.Page> _pages = [];

  late List<pageClass.Page> _topScrollable;
  late List<pageClass.Page> _bottomScrollable;

  late ScrollController _scrollController;

  GlobalKey _centerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _pages = _generatePages(_startIndex, _endIndex);
    _topScrollable = [];
    _bottomScrollable = _pages;

    _scrollController = ScrollController()..addListener(_overscroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _overscroll() {
    // reached the end and overscroll
    if (_scrollController.offset > _scrollController.position.maxScrollExtent + 60) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

      // add 10 pages
      setState(() {
        List<pageClass.Page> _newPages = _generatePages(_endIndex + 1, _endIndex + 10);
        _endIndex += 10;
        _bottomScrollable = _bottomScrollable + _newPages;
        _pages = _pages + _newPages;

        // set a random page to jump to by the floating button
        Random _rng = Random();
        _indexToJumpTo = _rng.nextInt(_endIndex - _startIndex) + _startIndex;
      });
    }

    // reached the beginning and overscroll
    if (_scrollController.offset < _scrollController.position.minScrollExtent - 60) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);

      // add 10 pages
      setState(() {
        List<pageClass.Page> _newPages = _generatePages(_startIndex - 10, _startIndex - 1);
        _startIndex -= 10;
        _topScrollable = _topScrollable + _newPages.reversed.toList();
        _pages = _newPages + _pages;

        // set a random page to jump to by the floating button
        Random _rng = Random();
        _indexToJumpTo = _rng.nextInt(_endIndex - _startIndex) + _startIndex;
      });
    }
  }

  List<pageClass.Page> _generatePages(int startIndex, int endIndex) {
    int _length = endIndex - startIndex + 1;

    return List.generate(_length, (index) {
      Random _rng = Random();

      double _height = _rng.nextDouble() * 300 + 200;
      Color _color = Color((_rng.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

      return pageClass.Page(
        index: startIndex + index,
        height: _height,
        color: _color,
      );
    });
  }

  void _jumpToIndex(int index) {
    setState(() {
      _topScrollable = _pages.sublist(0, index - _startIndex).reversed.toList();
      _bottomScrollable = _pages.sublist(index - _startIndex);
    });

    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: UnboundedCustomScrollView(
        center: _centerKey,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  'Overscroll to load more',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // top scrollable
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: _topScrollable[index].height,
                  color: _topScrollable[index].color,
                  child: Center(
                    child: Text(
                      _topScrollable[index].index.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              childCount: _topScrollable.length,
            ),
          ),
          // bottom scrollable
          SliverList(
            key: _centerKey,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  height: _bottomScrollable[index].height,
                  color: _bottomScrollable[index].color,
                  child: Center(
                    child: Text(
                      _bottomScrollable[index].index.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              childCount: _bottomScrollable.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  'Overscroll to load more',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _jumpToIndex(_indexToJumpTo);
        },
        label: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.shortcut,
                size: 20,
              ),
            ),
            Text(_indexToJumpTo.toString()),
          ],
        ),
      ),
    );
  }
}
