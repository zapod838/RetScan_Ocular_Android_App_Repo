import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final String iconImagePath;
  final VoidCallback onTap;

  const CategoryCard({
    required this.categoryName,
    required this.iconImagePath,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF9fbdff),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Image.asset(iconImagePath, height: 30),
              SizedBox(width: 10),
              Text(categoryName),
            ],
          ),
        ),
      ),
    );
  }
}
