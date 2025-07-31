import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../widgets/class_details_dialog.dart';
import '../../services/cart_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> filteredClasses = [];

  // Cache for teacher names to avoid repeated database calls
  Map<String, String> teacherCache = {};

  // Search controllers
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedDayOfWeek;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

  // Color scheme for different class types
  final Map<String, List<Color>> _classTypeColors = {
    'Flow Yoga': [const Color(0xFF6B73FF), const Color(0xFF9B59B6)],
    'Aerial Yoga': [const Color(0xFF00C9FF), const Color(0xFF92FE9D)],
    'Family Yoga': [const Color(0xFFFC466B), const Color(0xFF3F5EFB)],
    'Default': [const Color(0xFF667eea), const Color(0xFF764ba2)],
  };

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    loadClassesWithCoursesAndDetails();
    _searchController.addListener(_filterClasses);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Get gradient colors for class type
  List<Color> _getClassTypeColors(String classType) {
    return _classTypeColors[classType] ?? _classTypeColors['Default']!;
  }

  // Function to get teacher name by teacherId
  Future<String> getTeacherName(String teacherId) async {
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
        teacherCache[teacherId] = teacherName;
        return teacherName;
      } else {
        teacherCache[teacherId] = 'Unknown Teacher';
        return 'Unknown Teacher';
      }
    } catch (e) {
      teacherCache[teacherId] = 'Error loading teacher';
      return 'Error loading teacher';
    }
  }

  // Function to load classes with their courses and class details
  Future<void> loadClassesWithCoursesAndDetails() async {
    try {
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref(
        'classes',
      );
      DataSnapshot snapshot = await databaseReference.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> tempClasses = [];

        for (var classEntry in data.entries) {
          String classId = classEntry.key;
          Map<dynamic, dynamic> classData = classEntry.value;

          // Get teacher name
          String teacherId = classData['teacher'] ?? '';
          String teacherName = await getTeacherName(teacherId);

          // Process courses for this class
          List<Map<String, dynamic>> coursesList = [];

          if (classData['courses'] != null) {
            Map<dynamic, dynamic> courses = classData['courses'];

            for (var courseEntry in courses.entries) {
              String courseId = courseEntry.key;
              Map<dynamic, dynamic> courseData = courseEntry.value;

              // Process classDetails for this course
              List<Map<String, dynamic>> classDetailsList = [];

              if (courseData['classDetails'] != null) {
                Map<dynamic, dynamic> classDetails = courseData['classDetails'];

                for (var detailEntry in classDetails.entries) {
                  String detailId = detailEntry.key;
                  Map<dynamic, dynamic> detailData = detailEntry.value;

                  classDetailsList.add({
                    'id': detailId,
                    'capacity': detailData['capacity']?.toString() ?? '0',
                    'class_name': detailData['class_name'] ?? 'Unknown Class',
                    'createdTime': detailData['createdTime']?.toString() ?? '',
                    'date': detailData['date'] ?? '',
                    'description':
                        detailData['description'] ?? 'No description available',
                    'duration': detailData['duration']?.toString() ?? '0',
                    'localId': detailData['localId']?.toString() ?? '',
                    'price': detailData['price']?.toString() ?? '0',
                    'synced': detailData['synced'] ?? false,
                    'teacher': detailData['teacher'] ?? teacherId,
                    'teacherName': teacherName,
                    'type_of_class': detailData['type_of_class'] ?? 'Unknown',
                  });
                }
              }

              coursesList.add({
                'courseId': courseId,
                'classType': courseData['classType'] ?? 'Unknown',
                'totalClasses': courseData['totalClasses'] ?? 0,
                'totalPrice': courseData['totalPrice'] ?? 0,
                'classDetails': classDetailsList,
              });
            }
          }

          tempClasses.add({
            'classId': classId,
            'capacity': classData['capacity']?.toString() ?? '0',
            'createdTime': classData['createdTime']?.toString() ?? '',
            'day_of_week': classData['day_of_week'] ?? 'Unknown',
            'description':
                classData['description'] ?? 'No description available',
            'duration': classData['duration']?.toString() ?? '0',
            'localId': classData['localId']?.toString() ?? '',
            'price_per_class': classData['price_per_class']?.toString() ?? '0',
            'synced': classData['synced'] ?? false,
            'time_of_course': classData['time_of_course']?.toString() ?? '0',
            'type_of_class': classData['type_of_class'] ?? 'Unknown',
            'teacherName': teacherName,
            'courses': coursesList,
          });
        }

        if (mounted) {
          setState(() {
            classes = tempClasses;
            filteredClasses = tempClasses;
          });
        }
      }
    } catch (e) {
      print('Error loading classes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error loading classes: $e'),
              ],
            ),
            backgroundColor: const Color(0xFFE74C3C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Function to filter classes based on search criteria
  void _filterClasses() {
    if (mounted) {
      setState(() {
        filteredClasses = classes.where((classItem) {
          // Search in class name and course class details
          bool classNameMatch = classItem['type_of_class']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

          // Also search in course class details
          bool courseMatch = false;
          for (var course in classItem['courses']) {
            for (var detail in course['classDetails']) {
              if (detail['class_name'].toString().toLowerCase().contains(
                _searchController.text.toLowerCase(),
              )) {
                courseMatch = true;
                break;
              }
            }
            if (courseMatch) break;
          }

          bool dayOfWeekMatch = true;
          if (_selectedDate != null) {
            String selectedDayName =
                _dayOfWeekMap[_selectedDate!.weekday] ?? '';
            dayOfWeekMatch = classItem['day_of_week']
                .toString()
                .toLowerCase()
                .contains(selectedDayName.toLowerCase());
          }

          return (classNameMatch || courseMatch) && dayOfWeekMatch;
        }).toList();
      });
    }
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B73FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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

  // Function to show class details dialog
  void _showClassDetailsDialog(
    BuildContext context,
    Map<String, dynamic> classData,
  ) async {
    final result = await ClassDetailsDialog.show(context, classData);

    if (mounted && result != null) {
      if (result == 'already_in_cart') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${classData['class_name']} is already in your cart',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (result == 'added_to_cart') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Added ${classData['class_name']} to cart'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8F9FA), Color(0xFFE8F4FD)],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Modern Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'What type of class are you looking for?',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterClasses();
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Enhanced Date Filter
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: _selectedDate != null
                                                  ? [
                                                      const Color(0xFF667eea),
                                                      const Color(0xFF764ba2),
                                                    ]
                                                  : [
                                                      Colors.grey[300]!,
                                                      Colors.grey[400]!,
                                                    ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _selectedDate != null
                                                ? 'Classes on $_selectedDayOfWeek'
                                                : 'Filter by day of week',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: _selectedDate != null
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: _selectedDate != null
                                                  ? const Color(0xFF667eea)
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedDate != null) ...[
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: _clearDateFilter,
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.red[400],
                                    size: 20,
                                  ),
                                  tooltip: 'Clear date filter',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: filteredClasses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey[200]!,
                                      Colors.grey[300]!,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No classes found',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredClasses.length,
                          itemBuilder: (context, index) {
                            final classItem = filteredClasses[index];
                            final colors = _getClassTypeColors(
                              classItem['type_of_class'],
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors[0].withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      // Parent Card - Enhanced with gradient header
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: colors,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    _getClassIcon(
                                                      classItem['type_of_class'],
                                                    ),
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        classItem['type_of_class'] ??
                                                            'Unknown Class Type',
                                                        style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                _buildInfoChip(
                                                  Icons.calendar_today,
                                                  classItem['day_of_week'],
                                                ),
                                                const SizedBox(width: 12),
                                                _buildInfoChip(
                                                  Icons.access_time,
                                                  '${classItem['duration']} min',
                                                ),
                                                const SizedBox(width: 12),
                                                _buildInfoChip(
                                                  Icons.attach_money,
                                                  classItem['price_per_class'],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            if (classItem['courses'] != null &&
                                                (classItem['courses'] as List)
                                                    .isNotEmpty)
                                              ...((classItem['courses']
                                                      as List<
                                                        Map<String, dynamic>
                                                      >)
                                                  .expand(
                                                    (course) =>
                                                        course['classDetails']
                                                            as List<
                                                              Map<
                                                                String,
                                                                dynamic
                                                              >
                                                            >,
                                                  )
                                                  .map(
                                                    (classDetail) => Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                        border: Border.all(
                                                          color: colors[0]
                                                              .withOpacity(0.1),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                          onTap: () =>
                                                              _showClassDetailsDialog(
                                                                context,
                                                                classDetail,
                                                              ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  16,
                                                                ),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 4,
                                                                  height: 60,
                                                                  decoration: BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment
                                                                          .bottomCenter,
                                                                      colors:
                                                                          colors,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 16,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        classDetail['class_name'] ??
                                                                            'Unknown Class',
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: Color(
                                                                            0xFF2C3E50,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            4,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.event,
                                                                            size:
                                                                                14,
                                                                            color:
                                                                                Colors.grey[500],
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            classDetail['date'] ??
                                                                                '',
                                                                            style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey[600],
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                16,
                                                                          ),
                                                                          Icon(
                                                                            Icons.people,
                                                                            size:
                                                                                14,
                                                                            color:
                                                                                Colors.grey[500],
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            '${classDetail['capacity']} spots',
                                                                            style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey[600],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        classDetail['description'] ??
                                                                            'No description available',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey[600],
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 4,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                colors: colors,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(
                                                                                12,
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              '\$${classDetail['price']}',
                                                                              style: const TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 4,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color: colors[0].withOpacity(
                                                                                0.1,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(
                                                                                12,
                                                                              ),
                                                                            ),
                                                                            child: Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.touch_app,
                                                                                  size: 12,
                                                                                  color: colors[0],
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 4,
                                                                                ),
                                                                                Text(
                                                                                  'Tap for details',
                                                                                  style: TextStyle(
                                                                                    fontSize: 10,
                                                                                    color: colors[0],
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 16,
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                          colors:
                                                                              colors,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          15,
                                                                        ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: colors[0]
                                                                            .withOpacity(
                                                                              0.3,
                                                                            ),
                                                                        blurRadius:
                                                                            8,
                                                                        offset:
                                                                            const Offset(
                                                                              0,
                                                                              4,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    child: InkWell(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            15,
                                                                          ),
                                                                      onTap: () {
                                                                        final cartService =
                                                                            CartService();
                                                                        if (cartService.isInCart(
                                                                          classDetail['id'],
                                                                        )) {
                                                                          if (mounted) {
                                                                            ScaffoldMessenger.of(
                                                                              context,
                                                                            ).showSnackBar(
                                                                              SnackBar(
                                                                                content: Row(
                                                                                  children: [
                                                                                    const Icon(
                                                                                      Icons.info_outline,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 8,
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        '${classDetail['class_name']} is already in your cart',
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                backgroundColor: const Color(
                                                                                  0xFFFF9800,
                                                                                ),
                                                                                behavior: SnackBarBehavior.floating,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                        } else {
                                                                          cartService.addToCart(
                                                                            classDetail,
                                                                          );
                                                                          if (mounted) {
                                                                            ScaffoldMessenger.of(
                                                                              context,
                                                                            ).showSnackBar(
                                                                              SnackBar(
                                                                                content: Row(
                                                                                  children: [
                                                                                    const Icon(
                                                                                      Icons.check_circle_outline,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 8,
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        'Added ${classDetail['class_name']} to cart',
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                backgroundColor: const Color(
                                                                                  0xFF4CAF50,
                                                                                ),
                                                                                behavior: SnackBarBehavior.floating,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                        }
                                                                      },
                                                                      child: Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              12,
                                                                            ),
                                                                        child: const Icon(
                                                                          Icons
                                                                              .add_shopping_cart,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList())
                                            else
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                    color: Colors.grey[200]!,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.event_busy,
                                                      color: Colors.grey[400],
                                                      size: 32,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'No class sessions available',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Text(
                                                      'Check back later for upcoming sessions',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[500],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build info chips
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get class-specific icons
  IconData _getClassIcon(String classType) {
    switch (classType.toLowerCase()) {
      case 'flow yoga':
        return Icons.self_improvement;
      case 'family yoga':
        return Icons.spa;
      case 'aerial yoga':
        return Icons.fitness_center;
      default:
        return Icons.apps_outlined;
    }
  }
}
