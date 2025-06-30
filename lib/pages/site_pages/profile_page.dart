import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:comp1876_su25_crossapp/services/session_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final sessionService = SessionService();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Load data using the optimized method
    loadUserDataOptimized();
  }

  // Method to load cached data first, then fresh data from Realtime Database only
  Future<void> loadUserDataOptimized() async {
    try {
      if (!sessionService.isLoggedIn) {
        setState(() {
          errorMessage = 'No user is currently logged in';
          isLoading = false;
        });
        return;
      }

      // Step 1: Try to get cached data first for instant display
      Map<String, dynamic>? cachedData = await sessionService
          .getCachedUserData();

      if (cachedData != null) {
        print('ProfilePage: Displaying cached session data');
        print('Cached data: $cachedData');
        setState(() {
          userData = cachedData;
          isLoading = false;
        });
      } else {
        print(
          'ProfilePage: No cached data found, fetching from Realtime Database only',
        );

        // Step 2: If no cached data, fetch from Realtime Database only
        String? userId = sessionService.currentUserId;
        if (userId != null) {
          await fetchFromRealtimeDatabaseOnly(userId);
        } else {
          setState(() {
            errorMessage = 'Unable to get user ID';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading user data: $e';
        isLoading = false;
      });
    }
  }

  // Fetch data only from Realtime Database (no Firebase Auth metadata)
  Future<void> fetchFromRealtimeDatabaseOnly(String userId) async {
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.ref(
        'users/$userId',
      );
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        final dbData = snapshot.value;
        Map<String, dynamic> userData = {};

        // Handle different data types from Firebase Realtime Database
        if (dbData is Map) {
          dbData.forEach((key, value) {
            userData[key.toString()] = value;
          });

          print('Successfully fetched user data from Realtime Database only');
          print('Database data: $userData');

          // Cache the data for future use
          await sessionService.cacheUserData(userData);

          setState(() {
            this.userData = userData;
            isLoading = false;
          });
        } else {
          print(
            'Unexpected data format from Realtime Database: ${dbData.runtimeType}',
          );
          setState(() {
            errorMessage = 'Invalid data format from database';
            isLoading = false;
          });
        }
      } else {
        print('No user data found in Realtime Database for user: $userId');
        setState(() {
          errorMessage = 'No user profile data found in database';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching from database: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      // Use SessionService for proper logout (clears both Firebase Auth and cached data)
      await sessionService.clearSession();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading profile...'),
                  ],
                ),
              )
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        loadUserDataOptimized();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(
                              0xFFFF3333,
                            ).withOpacity(0.1),
                            backgroundImage: userData!['photoURL'] != null
                                ? NetworkImage(userData!['photoURL'])
                                : null,
                            child: userData!['photoURL'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: const Color(0xFFFF3333),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userData!['name'] ?? 'No name set',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData!['email'] ?? 'No email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Profile Information from Registration Data
                    _buildSectionTitle('Account Information'),
                    _buildInfoCard([
                      _buildInfoRow('User ID', userData!['uid'] ?? 'Unknown'),
                      _buildInfoRow('Email', userData!['email'] ?? 'Not set'),
                      _buildInfoRow(
                        'Full Name',
                        userData!['name'] ?? 'Not set',
                      ),
                      _buildInfoRow(
                        'Age',
                        userData!['age']?.toString() ?? 'Not set',
                      ),
                      _buildInfoRow('Phone', userData!['phone'] ?? 'Not set'),
                      if (userData!.containsKey('createdAt'))
                        _buildInfoRow(
                          'Registration Date',
                          _formatDateTime(userData!['createdAt']),
                        ),
                    ]),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Force refresh from Realtime Database only
                              setState(() {
                                isLoading = true;
                              });

                              String? userId = sessionService.currentUserId;
                              if (userId != null) {
                                await fetchFromRealtimeDatabaseOnly(userId);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Profile refreshed from database!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() {
                                  errorMessage =
                                      'Unable to get user ID for refresh';
                                  isLoading = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3333),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showSignOutDialog,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF3333),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
