import 'package:flutter/material.dart';
import 'dart:math';

import '../core/theme.dart';
import 'quote_model.dart';

/// Quote tile widget for displaying quotes
class QuoteTile extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onLongPress;

  const QuoteTile({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onAddToCollection,
    this.onLongPress,
  });

  Color _getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = AppTheme.getQuoteCardColors(brightness);
    final index = quote.id.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote Text
              Text(
                '"${quote.text}"',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Author
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '— ${quote.author}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withOpacity(0.8) : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onAddToCollection != null)
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade700,
                      ),
                      onPressed: onAddToCollection,
                      tooltip: 'Add to collection',
                    ),
                  if (onFavoriteTap != null)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : (isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade700),
                      ),
                      onPressed: onFavoriteTap,
                      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
