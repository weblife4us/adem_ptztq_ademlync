import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chore/main_bloc.dart';
import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import '../ui_specification.dart';
import 's_text.dart';
import 'svg_image.dart';

const _duration = Duration(milliseconds: 300);
const _curve = Curves.easeInOutCubic;

class SBottomNavigationBar extends StatefulWidget {
  final List<NavBarItem> items;
  final NavBarItem active;
  final void Function(String) onChanged;

  const SBottomNavigationBar({
    super.key,
    required this.items,
    required this.active,
    required this.onChanged,
  });

  @override
  State<SBottomNavigationBar> createState() => _SBottomNavigationBarState();
}

class _SBottomNavigationBarState extends State<SBottomNavigationBar> {
  late NavBarItem _active = widget.active;

  final _rowKey = GlobalKey();
  final _rowPadding = 12.0;
  final _radius = 14.0;

  double _rowWidth = 0.0;
  double _rowHeight = 0.0;
  NavBarItem? _hoveredItem;
  double _indicatorLeft = 0.0;
  bool _isInteracting = false;

  List<NavBarItem> get _items => widget.items;

  double get _itemWidth => _rowWidth / _items.length;

  double get _itemHeight => (_rowHeight - _rowPadding).clamp(0.0, _rowHeight);

  double get _snappedLeftOffset =>
      _rowPadding + _items.indexOf(_hoveredItem ?? _active) * _itemWidth;

  double get _topOffset => _rowPadding / 2.0;

  Duration get _currentDuration => _isInteracting ? Duration.zero : _duration;

  double get _currentLeft =>
      _isInteracting ? _indicatorLeft : _snappedLeftOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _updateRowSize())
      ..addObserver(_OrientationChangeHandler(this));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_OrientationChangeHandler(this));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<MainBloc>(context),
      listener: (_, state) {
        if (state case MBBtDisconnectedState state
            when state.isAutoDisconnected) {
          setState(() => _active = NavBarItem.setup);
        }
      },
      child: _NavBarBox(
        radius: _radius,
        child: GestureDetector(
          onTapDown: (details) => _startInteraction(details.localPosition.dx),
          onTapCancel: _endInteractionWithoutNavigate,
          onHorizontalDragStart: (details) =>
              _startInteraction(details.localPosition.dx),
          onHorizontalDragUpdate: (details) =>
              _updateInteraction(details.localPosition.dx),
          onHorizontalDragEnd: (_) => _endInteractionWithNavigate(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: _currentDuration,
                curve: _curve,
                left: _currentLeft,
                top: _topOffset,
                child: AnimatedScale(
                  duration: _duration,
                  curve: _curve,
                  scale: _isInteracting ? 1.1 : 1.0,
                  child: _HighlightIndicator(
                    hoverItem: _hoveredItem,
                    width: _itemWidth,
                    height: _itemHeight,
                    radius: _radius,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _rowPadding),
                child: Row(
                  key: _rowKey,
                  children: [
                    for (var o in _items)
                      Expanded(
                        child: _NavBarItem(
                          itemVerticalPadding: _rowPadding,
                          type: o,
                          isActive: _active == o && _hoveredItem == null,
                          isHovered: _hoveredItem == o,
                          onPressed: _updateActiveItem,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startInteraction(double dx) {
    setState(() {
      _isInteracting = true;
      final index = _updateHoverItemFromDx(dx);
      _indicatorLeft = (_rowPadding + index * _itemWidth).clamp(
        _rowPadding,
        _rowWidth - _itemWidth + _rowPadding,
      );
    });
  }

  void _updateInteraction(double dx) {
    setState(() {
      _updateHoverItemFromDx(dx);
      _indicatorLeft = (dx - _itemWidth / 2).clamp(
        _rowPadding,
        _rowWidth - _itemWidth + _rowPadding,
      );
    });
  }

  void _endInteractionWithoutNavigate() {
    setState(() {
      _isInteracting = false;
      _hoveredItem = null;
    });
  }

  void _endInteractionWithNavigate() {
    setState(() => _isInteracting = false);
    _updateActiveItem(_hoveredItem);
  }

  int _updateHoverItemFromDx(double dx) {
    final itemIndex = ((dx - _rowPadding) / _itemWidth)
        .clamp(0.0, _items.length - 1)
        .floor();
    _hoveredItem = _items[itemIndex];
    return itemIndex;
  }

  void _updateActiveItem(NavBarItem? item) {
    if (item == null) return;

    setState(() {
      _active = item;
      _hoveredItem = null;
    });

    widget.onChanged(_active.route);
  }

  void _updateRowSize() {
    final size = _rowKey.currentContext?.size;

    setState(() {
      _rowWidth = size?.width ?? 0.0;
      _rowHeight = size?.height ?? 0.0;
      _indicatorLeft = _snappedLeftOffset;
    });
  }
}

class _NavBarBox extends StatelessWidget {
  final double radius;
  final Widget child;

  const _NavBarBox({required this.radius, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
      decoration: BoxDecoration(
        color: colorScheme.cardBackground(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.grey.withValues(alpha: 0.3),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
            spreadRadius: 2.0,
          ),
        ],
      ),
      constraints: const BoxConstraints(
        maxWidth: UISpecification.maxWidthForTablet,
      ),
      child: child,
    );
  }
}

class _HighlightIndicator extends StatelessWidget {
  final NavBarItem? hoverItem;
  final double width;
  final double height;
  final double radius;

  const _HighlightIndicator({
    required this.hoverItem,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.buttonBackground(context),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.grey.withValues(alpha: 0.3),
            blurRadius: 10.0,
            offset: const Offset(0.0, 4.0),
            spreadRadius: 2.0,
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final double itemVerticalPadding;
  final bool isActive;
  final bool isHovered;
  final NavBarItem type;
  final void Function(NavBarItem) onPressed;

  const _NavBarItem({
    required this.itemVerticalPadding,
    required this.isActive,
    required this.isHovered,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = isActive || isHovered;
    return InkWell(
      onTap: () => onPressed(type),
      child: AnimatedScale(
        duration: _duration,
        curve: _curve,
        scale: isHighlighted ? 1.1 : 1.0,
        child: AnimatedOpacity(
          duration: _duration,
          curve: _curve,
          opacity: isHighlighted ? 1.0 : 0.7,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: itemVerticalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgImage(
                  type.icon,
                  color: isHighlighted
                      ? colorScheme.white(context)
                      : colorScheme.text(context),
                ),
                Text(
                  textScaler: TextScaler.noScaling,
                  style: STextStyle.titleSmall.style.copyWith(
                    fontSize: 10.0,
                    color: isHighlighted
                        ? colorScheme.white(context)
                        : colorScheme.text(context),
                    fontFamily: 'Madera',
                  ),
                  type.title,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrientationChangeHandler extends WidgetsBindingObserver {
  final _SBottomNavigationBarState _state;

  _OrientationChangeHandler(this._state);

  @override
  void didChangeMetrics() => _state._updateRowSize();
}

enum NavBarItem {
  setup('/setup'),
  check('/check'),
  calibration('/calibration'),
  dpCalculator('/dpCalculator'),
  logs('/log'),
  cloud('/cloud');

  final String route;
  const NavBarItem(this.route);

  String get icon => switch (this) {
    NavBarItem.setup => 'setup',
    NavBarItem.check => 'check',
    NavBarItem.calibration => 'calibration',
    NavBarItem.dpCalculator => 'dp',
    NavBarItem.logs => 'log',
    NavBarItem.cloud => 'cloud',
  };

  String get title => switch (this) {
    NavBarItem.setup => 'Setup',
    NavBarItem.check => 'Check',
    NavBarItem.calibration => 'Calibrate',
    NavBarItem.dpCalculator => 'D.P.',
    NavBarItem.logs => 'Logs',
    NavBarItem.cloud => 'Cloud',
  };
}
