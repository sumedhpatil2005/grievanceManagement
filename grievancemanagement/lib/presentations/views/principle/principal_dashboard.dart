import 'package:flutter/material.dart';
import 'package:grievancemanagement/data/models/complaint_model.dart';
import 'package:grievancemanagement/presentations/views/principle/assigncomplaint.dart';
import 'package:grievancemanagement/services/complaint_service.dart';
import 'package:grievancemanagement/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:grievancemanagement/presentations/views/login_screen.dart';

class PrincipleDashboard extends StatefulWidget {
  @override
  _PrincipleDashboardState createState() => _PrincipleDashboardState();
}

class _PrincipleDashboardState extends State<PrincipleDashboard> {
  final ComplaintService _complaintService = ComplaintService();
  int _selectedIndex = 0; // 0 for View Complaints, 1 for History

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Principle Dashboard',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
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
        child: Column(
          children: [
            // Tabs for View Complaints and History
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0; // Switch to View Complaints
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            _selectedIndex == 0
                                ? Colors.blue.shade900
                                : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _selectedIndex == 0
                                    ? Colors.blue.shade600
                                    : Colors.blue.shade100,

                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'View Complaints',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color:
                                _selectedIndex == 0
                                    ? Colors.white
                                    : Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1; // Switch to History
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            _selectedIndex == 1
                                ? Colors.blue.shade600
                                : Colors.blue.shade100,
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _selectedIndex == 1
                                    ? Colors.blue.shade900
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'History',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color:
                                _selectedIndex == 1
                                    ? Colors.white
                                    : Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Display complaints based on selected tab
            Expanded(
              child:
                  _selectedIndex == 0
                      ? _buildViewComplaints()
                      : _buildHistory(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the "View Complaints" section
  Widget _buildViewComplaints() {
    return StreamBuilder<List<Complaint>>(
      stream: _complaintService.getAllComplaints(),
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
              'No complaints found.',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          );
        }

        // Filter complaints for "View Complaints" (pending and assigned)
        final viewComplaints =
            snapshot.data!
                .where(
                  (complaint) =>
                      complaint.status == 'pending' ||
                      complaint.status == 'assigned',
                )
                .toList();

        return ListView.builder(
          itemCount: viewComplaints.length,
          itemBuilder: (context, index) {
            final complaint = viewComplaints[index];
            return _buildComplaintCard(complaint);
          },
        );
      },
    );
  }

  // Build the "History" section
  Widget _buildHistory() {
    return StreamBuilder<List<Complaint>>(
      stream: _complaintService.getAllComplaints(),
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
              'No resolved complaints found.',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          );
        }

        // Filter complaints for "History" (resolved)
        final resolvedComplaints =
            snapshot.data!
                .where((complaint) => complaint.status == 'resolved')
                .toList();

        return ListView.builder(
          itemCount: resolvedComplaints.length,
          itemBuilder: (context, index) {
            final complaint = resolvedComplaints[index];
            return _buildComplaintCard(complaint);
          },
        );
      },
    );
  }

  // Build a complaint card
  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
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
                'Raised By: ${complaint.studentName ?? 'Unknown Student'}',
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
                  'Assigned To: ${complaint.assignedTo}',
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
              complaint.status == 'pending'
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AssignComplaintScreen(
                                complaintId: complaint.id,
                              ),
                        ),
                      );
                      // Navigate to assign complaint screen
                    },
                    child: Text(
                      'Assign',
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
  }
}
