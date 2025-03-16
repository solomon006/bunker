import 'package:flutter/material.dart';

class PostApocalypticButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final double width;
  final double height;
  final Color accentColor;
  final Gradient? gradient;

  const PostApocalypticButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.width = 200,
    this.height = 50,
    this.accentColor = Colors.brown,
    this.gradient,
  }) : super(key: key);

  @override
  State<PostApocalypticButton> createState() => _PostApocalypticButtonState();
}

class _PostApocalypticButtonState extends State<PostApocalypticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown:
          isEnabled
              ? (_) {
                setState(() => _isPressed = true);
                _animationController.forward();
              }
              : null,
      onTapUp:
          isEnabled
              ? (_) {
                setState(() => _isPressed = false);
                _animationController.reverse();
                widget.onPressed?.call();
              }
              : null,
      onTapCancel:
          isEnabled
              ? () {
                setState(() => _isPressed = false);
                _animationController.reverse();
              }
              : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color:
                    isEnabled
                        ? (_isPressed
                            ? widget.accentColor.withOpacity(0.7)
                            : widget.accentColor)
                        : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                boxShadow:
                    _isPressed || !isEnabled
                        ? []
                        : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                gradient: isEnabled ? widget.gradient : null,
                border: Border.all(
                  color: Colors.black.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  if (!_isPressed && isEnabled)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color:
                                isEnabled
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color:
                                isEnabled
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
