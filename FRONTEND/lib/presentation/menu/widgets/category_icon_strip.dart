import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryIconStrip extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final Map<String, String>? iconAssetByCategoryId; // id -> asset path
  final ValueChanged<String> onSelected;
  
  // Add subtitle map parameter
  final Map<String, String>? subtitleByCategoryId; // id -> subtitle text

  const CategoryIconStrip({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.iconAssetByCategoryId,
    this.subtitleByCategoryId, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF1E1E1E);
    const border = Color(0xFF2A2A2A);
    final accent = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 110, // Increased height to accommodate subtitle
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = categories[i];
          final sel = c.id == selectedId;
          final iconPath = iconAssetByCategoryId?[c.id];
          final subtitle = subtitleByCategoryId?[c.id]; // Get subtitle

          return InkWell(
            onTap: () => onSelected(c.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 88,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sel ? accent : border, width: sel ? 2 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  if (iconPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(iconPath, width: 28, height: 28, fit: BoxFit.cover),
                    )
                  else
                    Icon(Icons.category_outlined,
                        size: 26, color: sel ? accent : const Color(0xFFA7A7A7)),
                  const SizedBox(height: 6),
                  
                  // Category name
                  Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : const Color(0xFFEDEDED),
                    ),
                  ),
                  
                  // Subtitle (if provided)
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF888888), // Gray color
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}