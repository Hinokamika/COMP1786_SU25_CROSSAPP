import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../widgets/class_details_dialog.dart';
import '../../services/cart_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample data for the ListView - you can replace this with your actual data
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];

  // Cache for teacher names to avoid repeated database calls
  Map<String, String> teacherCache = {};

  // Search controllers
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedDayOfWeek;

  // Days of the week mapping
  final Map<int, String> _dayOfWeekMap = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @override
  void initState() {
    super.initState();
    loadClassesWithTeachers();
    _searchController.addListener(_filterClasses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to get teacher name by teacherId
  Future<String> getTeacherName(String teacherId) async {
    // Check if teacher name is already cached
    if (teacherCache.containsKey(teacherId)) {
      return teacherCache[teacherId]!;
    }

    try {
      DatabaseReference teacherRef = FirebaseDatabase.instance.ref(
        'teachers/$teacherId',
      );
      DataSnapshot snapshot = await teacherRef.get();

      if (snapshot.exists) {
        final teacherData = snapshot.value as Map<dynamic, dynamic>;
        String teacherName =
            teacherData['name'] ??
            teacherData['teacherName'] ??
            'Unknown Teacher';

        // Cache the result for future use
        teacherCache[teacherId] = teacherName;
        return teacherName;
      } else {
        // Cache the unknown result to avoid repeated calls
        teacherCache[teacherId] = 'Unknown Teacher';
        return 'Unknown Teacher';
      }
    } catch (e) {
      print('Error fetching teacher name: $e');
      teacherCache[teacherId] = 'Error loading teacher';
      return 'Error loading teacher';
    }
  }

  // Function to load classes and resolve teacher names
  Future<void> loadClassesWithTeachers() async {
    try {
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref(
        'classes',
      );
      DataSnapshot snapshot = await databaseReference.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> tempItems = [];

        for (var entry in data.entries) {
          String teacherId =
              entry.value['teacher'] ?? entry.value['teacherId'] ?? '';
          String teacherName = await getTeacherName(teacherId);

          tempItems.add({
            'id': entry.key,
            'class_name': entry.value['class_name'] ?? 'Unknown Class',
            'description':
                entry.value['description'] ?? 'No description available',
            'price_per_class': entry.value['price_per_class'] != null
                ? '\$${entry.value['price_per_class']}'
                : 'Free',
            'duration': entry.value['duration'] ?? '1 hour',
            'day_of_week': entry.value['day_of_week'] ?? '0-0-0',
            'capacity': entry.value['capacity'] ?? 0,
            'time_of_course': entry.value['time_of_course'] ?? '0',
            'type_of_class': entry.value['type_of_class'] ?? 'Unknown',
            'teacher': teacherName,
            'teacherId': teacherId,
          });
        }

        if (mounted) {
          setState(() {
            items = tempItems;
            filteredItems = tempItems; // Initialize filtered items
          });
        }
      }
    } catch (e) {
      print('Error loading classes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading classes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to show class details dialog
  void _showClassDetailsDialog(
    BuildContext context,
    Map<String, dynamic> classData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassDetailsDialog(classData: classData);
      },
    );
  }

  // Function to filter classes based on search criteria
  void _filterClasses() {
    if (mounted) {
      setState(() {
        filteredItems = items.where((item) {
          final classNameMatch = item['class_name']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

          bool dayOfWeekMatch = true;
          if (_selectedDate != null) {
            try {
              // Parse the YYYY-MM-DD format from the database
              final itemDateStr = item['day_of_week'].toString();
              if (itemDateStr != '0-0-0' && itemDateStr.isNotEmpty) {
                final itemDate = DateTime.parse(itemDateStr);
                // Compare the weekday (1 = Monday, 7 = Sunday)
                dayOfWeekMatch = itemDate.weekday == _selectedDate!.weekday;
              } else {
                dayOfWeekMatch = false;
              }
            } catch (e) {
              // If parsing fails, exclude this item from results
              dayOfWeekMatch = false;
            }
          }

          return classNameMatch && dayOfWeekMatch;
        }).toList();
      });
    }
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ), // Allow dates from 30 days ago
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
          _selectedDayOfWeek = _dayOfWeekMap[picked.weekday];
        });
        _filterClasses();
      }
    }
  }

  // Function to clear date filter
  void _clearDateFilter() {
    if (mounted) {
      setState(() {
        _selectedDate = null;
        _selectedDayOfWeek = null;
      });
      _filterClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Available Classes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Search by class name
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by class name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterClasses();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF3333)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date picker for day of week
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate != null
                                ? 'Classes on: $_selectedDayOfWeek'
                                : 'Filter by day of week',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: _selectedDate != null
                                  ? const Color(0xFFFF3333)
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                      ),
                      if (_selectedDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _clearDateFilter,
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear date filter',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No classes found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search criteria',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Card(
                            elevation: 4,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _showClassDetailsDialog(context, item);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['class_name'] ??
                                                'Unknown Class',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['description'] ??
                                                'No description available',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Teacher: ${item['teacher'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item['price_per_class'] ?? 'Free',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF3333),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        final cartService = CartService();
                                        if (cartService.isInCart(item['id'])) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${item['class_name']} is already in your cart',
                                                ),
                                                backgroundColor: Colors.orange,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          cartService.addToCart(item);
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Added ${item['class_name']} to cart',
                                                ),
                                                backgroundColor: Colors.green,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add_shopping_cart,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
