import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class ClassDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> classData;

  const ClassDetailsDialog({super.key, required this.classData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.school, color: const Color(0xFFFF3333), size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              classData['class_name'] ?? 'Unknown Class',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF3333),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(
              'Description',
              classData['description'] ?? 'No description available',
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Teacher', classData['teacher'] ?? 'Unknown'),
            const SizedBox(height: 12),
            _buildDetailRow('Duration', classData['duration'] ?? '1 hour'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Day of Week',
              classData['day_of_week'] ?? 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Time',
              classData['time_of_course'] ?? 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Capacity', '${classData['capacity'] ?? 0}'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Type of Class',
              classData['type_of_class'] ?? 'Unknown',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3333).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF3333), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'Price per Class',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    classData['price_per_class'] ?? 'Free',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF3333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final cartService = CartService();
            if (cartService.isInCart(classData['id'])) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${classData['class_name']} is already in your cart',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              cartService.addToCart(classData);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${classData['class_name']} to cart'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3333),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassDetailsDialog(classData: classData);
      },
    );
  }
}
