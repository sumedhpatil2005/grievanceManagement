import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grievancemanagement/services/complaint_service.dart';

class AssignComplaintScreen extends StatelessWidget {
  final String complaintId;
  final ComplaintService _complaintService = ComplaintService();

  AssignComplaintScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: Text(
          'Assign Complaint',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'moderator')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching moderators: ${snapshot.error}',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No moderators found.',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }

            final moderators = snapshot.data!.docs;
            return ListView.builder(
              itemCount: moderators.length,
              itemBuilder: (context, index) {
                final moderator = moderators[index];
                final moderatorData = moderator.data() as Map<String, dynamic>?;

                final moderatorId = moderator.id;
                final moderatorName = moderatorData?['name'] ?? 'Unknown Name';
                final moderatorEmail = moderatorData?['email'] ?? 'No Email';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                      title: Text(
                        moderatorName,
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      subtitle: Text(
                        moderatorEmail,
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      onTap: () async {
                        try {
                          // Fetch the complaint details to get studentName and department
                          final complaintDoc =
                              await FirebaseFirestore.instance
                                  .collection('complaints')
                                  .doc(complaintId)
                                  .get();

                          if (complaintDoc.exists) {
                            final complaintData =
                                complaintDoc.data() as Map<String, dynamic>;
                            final studentName =
                                complaintData['studentName'] ??
                                'Unknown Student';
                            final department =
                                complaintData['department'] ?? 'Not applicable';

                            // Assign the complaint with studentName and department
                            await _complaintService.assignComplaint(
                              complaintId,
                              moderatorId,
                              studentName,
                              department,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Complaint assigned successfully!',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Complaint not found.',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error assigning complaint: $e',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            ),
                          );
                        }
                      },
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
