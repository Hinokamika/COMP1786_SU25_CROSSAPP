import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class ClassDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> classData;

  const ClassDetailsDialog({super.key, required this.classData});

  Future<String> getTeacherName(String teacherId) async {
    try {
      final DatabaseReference teacherRef = FirebaseDatabase.instance
          .ref()
          .child('teachers')
          .child(teacherId);

      final DataSnapshot snapshot = await teacherRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> teacherData =
            snapshot.value as Map<dynamic, dynamic>;
        return teacherData['name']?.toString() ?? 'Unknown Teacher';
      }

      return 'Unknown Teacher';
    } catch (e) {
      print('Error getting teacher name: $e');
      return 'Unknown Teacher';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight:
              MediaQuery.of(context).size.height *
              0.85, // Limit height to 85% of screen
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classData['class_name'] ?? 'Unknown Class',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          classData['type_of_class'] ?? 'Class Details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content - Make it scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.description,
                      'Description',
                      classData['description'] ?? 'No description available',
                    ),
                    const SizedBox(height: 10),
                    // Teacher section with FutureBuilder
                    FutureBuilder<String>(
                      future: getTeacherName(classData['teacher'] ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildDetailRow(
                            Icons.person,
                            'Teacher',
                            'Loading...',
                          );
                        }
                        return _buildDetailRow(
                          Icons.person,
                          'Teacher',
                          snapshot.data ?? 'Unknown Teacher',
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailRow(
                            Icons.access_time,
                            'Duration',
                            '${classData['duration'] ?? '60'} min',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDetailRow(
                            Icons.people,
                            'Capacity',
                            '${classData['capacity'] ?? 0} spots',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Date',
                      classData['date'] ??
                          classData['day_of_week'] ??
                          'Not specified',
                    ),

                    const SizedBox(height: 15),

                    // Price section - Compact version
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.attach_money,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Price: \$${classData['price'] ?? classData['price_per_class'] ?? '0'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions - Fixed at bottom
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final cartService = CartService();
                        if (cartService.isInCart(classData['id'])) {
                          Navigator.of(context).pop('already_in_cart');
                        } else {
                          cartService.addToCart(classData);
                          Navigator.of(context).pop('added_to_cart');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF667eea)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> show(
    BuildContext context,
    Map<String, dynamic> classData,
  ) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return ClassDetailsDialog(classData: classData);
      },
    );
  }
}
