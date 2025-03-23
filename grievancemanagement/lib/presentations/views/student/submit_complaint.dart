import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grievancemanagement/data/models/complaint_model.dart';
import 'package:grievancemanagement/presentations/views/login_screen.dart';
import 'package:grievancemanagement/services/auth_service.dart';
import 'package:grievancemanagement/services/complaint_service.dart';

class SubmitComplaintScreen extends StatefulWidget {
  final String studentId;

  const SubmitComplaintScreen({super.key, required this.studentId});

  @override
  _SubmitComplaintScreenState createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Academic Issues';
  final ComplaintService _complaintService = ComplaintService();
  String _studentName = '';
  String _department = '';
  String _year = '';

  final List<String> _categories = [
    'Academic Issues',
    'Administrative Issues',
    'Infrastructure Issues',
    'Financial Issues',
    'Harassment & Discrimination',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    try {
      final studentDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.studentId)
              .get();

      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        setState(() {
          _studentName = studentData['name'] ?? 'Unknown Student';
          _department = studentData['department'] ?? 'Not applicable';
          _year = studentData['year'] ?? "Not found";
        });
      }
    } catch (e) {
      print('Error fetching student details: $e');
    }
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      final complaint = Complaint(
        studentName: _studentName, // Ensure this is included
        id: '', // Firestore will auto-generate this
        category: _selectedCategory,
        title: _titleController.text,
        description: _descriptionController.text,
        studentId: widget.studentId,
        status: 'pending',
        assignedTo: null,
        createdAt: DateTime.now(),
        updatedAt: null,
        department: _department,
        year: _year, // Ensure this is included
      );

      try {
        await _complaintService.submitComplaint(complaint);
        print('Complaint submitted successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully!')),
        );

        // Clear the form
        _titleController.clear();
        _descriptionController.clear();
      } catch (e) {
        print('Error submitting complaint: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting complaint: $e')),
        );
      }
    }
  }

  // Fetch moderator's name using their ID
  Future<String> _getModeratorName(String moderatorId) async {
    try {
      final moderatorDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(moderatorId)
              .get();

      if (moderatorDoc.exists) {
        final moderatorData = moderatorDoc.data() as Map<String, dynamic>;
        return moderatorData['name'] ?? 'Unknown Moderator';
      }
    } catch (e) {
      print('Error fetching moderator details: $e');
    }
    return 'Unknown Moderator';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: Text(
          'Submit Complaint',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Category Dropdown
                DropdownButtonFormField(
                  value: _selectedCategory,
                  items:
                      _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                // Submit Button
                ElevatedButton(
                  onPressed: _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit Complaint',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Complaint History Section
                Text(
                  'Complaint History',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    foreground:
                        Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Colors.blue.shade900,
                              Colors.blue.shade700,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('complaints')
                          .where('student_id', isEqualTo: widget.studentId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    // Debugging: Print connection state and data
                    print('Connection State: ${snapshot.connectionState}');
                    if (snapshot.hasData) {
                      print('Complaints Data: ${snapshot.data!.docs}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading complaints: ${snapshot.error}',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No complaints found.',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      );
                    }

                    final complaints = snapshot.data!.docs;
                    return Column(
                      children:
                          complaints.map((doc) {
                            final complaint = Complaint.fromMap(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                            return FutureBuilder<String>(
                              future:
                                  complaint.assignedTo != null
                                      ? _getModeratorName(complaint.assignedTo!)
                                      : Future.value('Not assigned'),
                              builder: (context, moderatorNameSnapshot) {
                                final moderatorName =
                                    moderatorNameSnapshot.data ?? 'Loading...';
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade100,
                                          Colors.white,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      title: Text(
                                        complaint.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Text(
                                            'Status: ${complaint.status}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          if (complaint.assignedTo != null)
                                            Text(
                                              'Assigned To: $moderatorName',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: _getStatusIcon(
                                        complaint.status,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get icons based on status
  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icon(Icons.access_time, color: Colors.orange);
      case 'assigned':
        return Icon(Icons.assignment_turned_in, color: Colors.blue);
      case 'resolved':
        return Icon(Icons.check_circle, color: Colors.green);
      default:
        return Icon(Icons.error, color: Colors.red);
    }
  }
}
