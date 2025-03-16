import 'package:flutter/material.dart';

class PostApocalypticCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color borderColor;

  const PostApocalypticCard({
    Key? key,
    required this.child,
    this.elevation = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.borderRadius,
    this.backgroundColor,
    this.borderColor = Colors.brown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBgColor = backgroundColor ?? theme.cardColor;
    final radius = borderRadius ?? BorderRadius.circular(12.0);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
        border: Border.all(
          color: borderColor.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/card_background.jpg'),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
