import 'package:flutter/material.dart';

class PostApocalypticSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;

  const PostApocalypticSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    required this.onChanged,
    this.activeColor = Colors.brown,
    this.inactiveColor = Colors.brown,
    this.thumbColor = Colors.brown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6.0,
        activeTrackColor: activeColor,
        inactiveTrackColor: inactiveColor.withOpacity(0.3),
        thumbColor: thumbColor,
        thumbShape: _PostApocalypticThumbShape(),
        overlayColor: thumbColor.withOpacity(0.2),
        valueIndicatorColor: thumbColor,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        trackShape: _PostApocalypticTrackShape(),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label ?? value.round().toString(),
        onChanged: onChanged,
      ),
    );
  }
}

class _PostApocalypticThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double disabledThumbRadius;

  _PostApocalypticThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius = 8.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? enabledThumbRadius : disabledThumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;
    final radius = enabledThumbRadius * enableAnimation.value;

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Рисуем тень
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center.translate(0, 1), radius: radius));
    canvas.drawShadow(shadowPath, Colors.black, 2.0, true);

    // Рисуем основное тело ползунка
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);

    // Добавляем декоративные элементы
    canvas.drawLine(
      Offset(center.dx - radius / 2, center.dy),
      Offset(center.dx + radius / 2, center.dy),
      borderPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius / 2),
      Offset(center.dx, center.dy + radius / 2),
      borderPaint,
    );
  }
}

class _PostApocalypticTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        double additionalActiveTrackHeight = 0,
        Offset? secondaryOffset, // Добавьте этот параметр
      }) {
    // Рисуем базовую дорожку
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );

    // Добавляем тени и детали
    final Canvas canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Добавляем тень под активной частью
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    final shadowRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top + 1,
      thumbCenter.dx,
      trackRect.bottom + 1,
    );
    canvas.drawRect(shadowRect, shadowPaint);

    // Добавляем блики на активной части
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final highlightPath = Path()
      ..moveTo(trackRect.left, trackRect.top)
      ..lineTo(thumbCenter.dx, trackRect.top);
    canvas.drawPath(highlightPath, highlightPaint);
  }
}
