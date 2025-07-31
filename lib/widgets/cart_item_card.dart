import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool showConfirmedBadge;
  final VoidCallback? onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    this.showConfirmedBadge = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.brightness == Brightness.dark
                ? Colors.grey[850]!.withOpacity(0.8)
                : Colors.white,
            theme.brightness == Brightness.dark
                ? Colors.grey[800]!.withOpacity(0.6)
                : const Color(0xFFFFF8E1),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.1),
            blurRadius: isSmallScreen ? 6 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Row(
          children: [
            _buildItemIcon(theme, isSmallScreen),
            SizedBox(width: isSmallScreen ? 12 : 16),
            _buildItemDetails(isSmallScreen),
            if (showConfirmedBadge) _buildConfirmedBadge(),
            if (!showConfirmedBadge && onRemove != null) _buildRemoveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon(ThemeData theme, bool isSmallScreen) {
    final iconSize = isSmallScreen ? 56.0 : 72.0;
    final iconInnerSize = isSmallScreen ? 28.0 : 36.0;

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: isSmallScreen ? 6 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.school_rounded,
        color: Colors.white,
        size: iconInnerSize,
      ),
    );
  }

  Widget _buildItemDetails(bool isSmallScreen) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'] ?? 'Unknown Class',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 10,
              vertical: isSmallScreen ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            ),
            child: Text(
              'Duration: ${item['duration'] ?? '1 hour'}',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13,
                color: const Color(0xFFFF9800),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            ),
            child: Text(
              '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Text(
        'Confirmed',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onRemove?.call();
        },
        icon: const Icon(Icons.remove_circle_rounded),
        color: const Color(0xFFFF5252),
        tooltip: 'Remove from cart',
        iconSize: 28,
      ),
    );
  }
}
