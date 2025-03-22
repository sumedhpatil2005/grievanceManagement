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
      body: StreamBuilder<List<Complaint>>(
        stream: _complaintService.getComplaintsForModerator(moderatorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No complaints assigned.'));
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
                    title: Text(complaint.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${complaint.category}'),
                        Text('Description: ${complaint.description}'),
                        Text('Status: ${complaint.status}'),
                        if (complaint.assignedTo != null)
                          Text('Assigned To: ${complaint.assignedTo}'),
                        Text(
                          'Created At: ${complaint.createdAt.toLocal().toString()}',
                        ),
                        if (complaint.updatedAt != null)
                          Text(
                            'Updated At: ${complaint.updatedAt!.toLocal().toString()}',
                          ),
                      ],
                    ),
                    trailing:
                        complaint.status == 'assigned'
                            ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                await _complaintService.updateComplaintStatus(
                                  complaint.id,
                                  'resolved',
                                );
                              },
                              child: Text('Mark Resolved'),
                            )
                            : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
