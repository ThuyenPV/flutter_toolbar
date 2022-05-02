library flutter_toolbar;

import 'package:flutter/material.dart';
import 'package:flutter_toolbar/src/constants.dart';
import 'package:flutter_toolbar/src/models/toolbar_item_data.dart';
import 'package:flutter_toolbar/src/widgets/toolbar_item.dart';

class FlutterToolbar extends StatefulWidget {
  const FlutterToolbar({
    Key? key,
    required this.toolbarItems,
  }) : super(key: key);

  final List<ToolbarItemData> toolbarItems;

  @override
  _FlutterToolbarState createState() => _FlutterToolbarState();
}

class _FlutterToolbarState extends State<FlutterToolbar> {
  late ScrollController scrollController;

  double get itemHeight => Constants.toolbarWidth - (Constants.toolbarHorizontalPadding * 2);

  List<double> itemScrollScaleValues = [];

  List<double> itemYPositions = [];

  List<bool> longPressedItemsFlags = [];

  void scrollListener() {
    if (scrollController.hasClients) {
      _updateItemsScrollData(
        scrollPosition: scrollController.position.pixels,
      );
    }
  }

  void _updateItemsScrollData({double scrollPosition = 0}) {
    List<double> _itemScrollScaleValues = [];
    List<double> _itemYPositions = [];
    for (int i = 0; i <= widget.toolbarItems.length - 1; i++) {
      double itemTopPosition = i * (itemHeight + Constants.itemsGutter);
      _itemYPositions.add(itemTopPosition - scrollPosition);

      double distanceToMaxScrollExtent = Constants.toolbarHeight + scrollPosition - itemTopPosition;
      double itemBottomPosition = (i + 1) * (itemHeight + Constants.itemsGutter);
      bool itemIsOutOfView = distanceToMaxScrollExtent < 0 || scrollPosition > itemBottomPosition;
      _itemScrollScaleValues.add(itemIsOutOfView ? 0.4 : 1);
    }
    setState(() {
      itemScrollScaleValues = _itemScrollScaleValues;
      itemYPositions = _itemYPositions;
    });
  }

  void _updateLongPressedItemsFlags({double longPressYLocation = 0}) {
    List<bool> _longPressedItemsFlags = [];
    for (int i = 0; i <= widget.toolbarItems.length - 1; i++) {
      bool isLongPressed = itemYPositions[i] >= 0 &&
          longPressYLocation > itemYPositions[i] &&
          longPressYLocation < (itemYPositions.length > i + 1 ? itemYPositions[i + 1] : Constants.toolbarHeight);
      _longPressedItemsFlags.add(isLongPressed);
    }
    setState(() {
      longPressedItemsFlags = _longPressedItemsFlags;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateItemsScrollData();
    _updateLongPressedItemsFlags();
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.toolbarHeight,
      margin: const EdgeInsets.only(left: 20, top: 90),
      child: Stack(
        children: [
          Positioned(
            child: Container(
              width: Constants.toolbarWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onLongPressStart: (LongPressStartDetails details) {
              _updateLongPressedItemsFlags(
                longPressYLocation: details.localPosition.dy,
              );
            },
            onLongPressMoveUpdate: (details) {
              _updateLongPressedItemsFlags(
                longPressYLocation: details.localPosition.dy,
              );
            },
            onLongPressEnd: (LongPressEndDetails details) {
              _updateLongPressedItemsFlags(longPressYLocation: 0);
            },
            onLongPressCancel: () {
              _updateLongPressedItemsFlags(longPressYLocation: 0);
            },
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: widget.toolbarItems.length,
              itemBuilder: (c, i) => ToolbarItem(
                widget.toolbarItems[i],
                height: itemHeight,
                scrollScale: itemScrollScaleValues[i],
                isLongPressed: longPressedItemsFlags[i],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
