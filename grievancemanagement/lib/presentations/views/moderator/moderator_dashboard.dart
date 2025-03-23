import 'package:flutter/material.dart';
import 'package:grievancemanagement/data/models/complaint_model.dart';
import 'package:grievancemanagement/presentations/views/login_screen.dart';
import 'package:grievancemanagement/services/auth_service.dart';
import 'package:grievancemanagement/services/complaint_service.dart';
import 'package:provider/provider.dart';

class ModeratorDashboard extends StatelessWidget {
  final String moderatorId;
  final ComplaintService _complaintService = ComplaintService();

  ModeratorDashboard({super.key, required this.moderatorId});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade600,
        title: Text(
          'Moderator Dashboard',
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
        child: StreamBuilder<List<Complaint>>(
          stream: _complaintService.getComplaintsForModerator(moderatorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No complaints assigned.',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }

            // Debug: Print the fetched complaints
            print('Fetched complaints: ${snapshot.data}');

            final complaints = snapshot.data!;

            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        complaint.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Raised By: ${complaint.studentName ?? 'Unknown Student'}', // Display student's name
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Category: ${complaint.category}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Description: ${complaint.description}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Status: ${complaint.status}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          if (complaint.assignedTo != null)
                            Text(
                              'Department: ${complaint.department}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          SizedBox(height: 8),
                          Text(
                            'Created At: ${complaint.createdAt.toLocal().toString()}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (complaint.updatedAt != null)
                            Text(
                              'Updated At: ${complaint.updatedAt!.toLocal().toString()}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                        ],
                      ),
                      trailing:
                          complaint.status == 'assigned'
                              ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await _complaintService.resolveComplaint(
                                      complaint.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Complaint marked as resolved.',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to resolve complaint: $e',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Mark Resolved',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              : complaint.status == 'resolved'
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
