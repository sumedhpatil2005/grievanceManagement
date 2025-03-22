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

  final List<String> _categories = [
    'Academic Issues',
    'Administrative Issues',
    'Infrastructure Issues',
    'Financial Issues',
    'Harassment & Discrimination',
  ];

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      final complaint = Complaint(
        studentName: '',
        id: '', // Firestore will auto-generate this
        category: _selectedCategory,
        title: _titleController.text,
        description: _descriptionController.text,
        studentId: widget.studentId,
        status: 'pending',
        assignedTo: null,
        createdAt: DateTime.now(),
        updatedAt: null,
        department: '',
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
                    fontSize: 24, // Slightly larger font size
                    fontWeight: FontWeight.bold, // Bold text
                    foreground:
                        Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Colors.blue.shade900, // Dark blue
                              Colors.blue.shade700, // Medium blue
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(
                            Rect.fromLTWH(0, 0, 200, 70),
                          ), // Gradient text effect
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Error loading complaints: ${snapshot.error}',
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text(
                        'No complaints found.',
                        style: TextStyle(fontFamily: 'Poppins'),
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
                            return Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ), // Add horizontal margin
                              elevation:
                                  5, // Increase elevation for a more prominent look
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ), // Increase border radius
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade100, // Light blue
                                      Colors.white, // White
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ), // Match card border radius
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(
                                    16,
                                  ), // Add padding inside ListTile
                                  title: Text(
                                    complaint.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600, // Semi-bold
                                      color:
                                          Colors
                                              .blue
                                              .shade900, // Dark blue text
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 8,
                                      ), // Add spacing between title and subtitle
                                      Text(
                                        complaint.status == 'pending'
                                            ? 'Status: Pending'
                                            : 'Status: Assigned to ${complaint.assignedTo}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade700, // Grey text for subtlety
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ), // Add spacing below subtitle
                                      if (complaint.assignedTo != null)
                                        Text(
                                          'Assigned To: ${complaint.assignedTo ?? 'not assigned to'}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade700, // Grey text for subtlety
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing:
                                      complaint.status == 'pending'
                                          ? Icon(
                                            Icons.access_time, // Pending icon
                                            color:
                                                Colors
                                                    .orange
                                                    .shade700, // Orange for pending status
                                          )
                                          : Icon(
                                            Icons.check_circle, // Assigned icon
                                            color:
                                                Colors
                                                    .green
                                                    .shade700, // Green for assigned status
                                          ),
                                ),
                              ),
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
}
