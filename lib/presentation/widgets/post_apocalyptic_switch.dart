import 'package:flutter/material.dart';

class PostApocalypticSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color trackColor;
  final double width;
  final double height;

  const PostApocalypticSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.brown,
    this.trackColor = Colors.grey,
    this.width = 60.0,
    this.height = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          onChanged!(!value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: value ? activeColor.withOpacity(0.5) : trackColor.withOpacity(0.3),
          border: Border.all(
            color: value ? activeColor : Colors.grey.shade600,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Текст индикатора состояния
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? 8 : width - 40,
              top: height / 2 - 8,
              child: Text(
                value ? 'ВКЛ' : 'ВЫКЛ',
                style: TextStyle(
                  color: value ? Colors.white : Colors.grey.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Переключатель
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? width - height + 4 : 4,
              top: 4,
              child: Container(
                width: height - 8,
                height: height - 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                // Добавляем "ржавые" декоративные элементы
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? activeColor : Colors.grey.shade400,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Декоративные "болты"
            Positioned(
              left: 4,
              top: height / 2,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: height / 2,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
