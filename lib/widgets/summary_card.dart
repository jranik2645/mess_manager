import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor = Colors.white,
    this.gradient,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? (backgroundColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white))
                : null,
            borderRadius: BorderRadius.circular(16),
            border: gradient == null
                ? Border.all(
                    color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                    width: 0.8,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: gradient != null
                            ? Colors.white.withAlpha(220)
                            : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: gradient != null
                          ? Colors.white.withAlpha(40)
                          : iconColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: gradient != null ? Colors.white : iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: gradient != null
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF163172)),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: gradient != null
                        ? Colors.white.withAlpha(200)
                        : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

