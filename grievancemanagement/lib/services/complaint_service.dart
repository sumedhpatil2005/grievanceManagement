import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grievancemanagement/data/models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a new complaint
  Future<void> submitComplaint(Complaint complaint) async {
    try {
      await _firestore.collection('complaints').add({
        'category': complaint.category,
        'title': complaint.title,
        'description': complaint.description,
        'student_id': complaint.studentId,
        'student_name': complaint.studentName, // Ensure this is included
        'department': complaint.department, // Ensure this is included
        'status': 'pending', // Default status
        'assigned_to': complaint.assignedTo, // Ensure this matches Firestore
        'created_at': Timestamp.now(),
        'updated_at': null,
        'year': complaint.year,
      });
    } catch (e) {
      throw Exception('Failed to submit complaint: $e');
    }
  }

  // Get all complaints assigned to moderators
  Stream<List<Complaint>> getAssignedComplaints() {
    return _firestore
        .collection('complaints')
        .where(
          'assigned_to',
          isNotEqualTo: null,
        ) // Fetch complaints with assigned moderators
        .orderBy('created_at', descending: true) // Order by creation date
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Complaint.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get complaints assigned to a specific moderator
  Stream<List<Complaint>> getComplaintsForModerator(String moderatorId) {
    return _firestore
        .collection('complaints')
        .where('assigned_to', isEqualTo: moderatorId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Complaint.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Update the status of a complaint
  Future<void> updateComplaintStatus(String complaintId, String status) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': status,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  // Mark a complaint as resolved
  Future<void> resolveComplaint(String complaintId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'resolved',
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to resolve complaint: $e');
    }
  }

  // Get all complaints (ordered by creation date)
  Stream<List<Complaint>> getAllComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Complaint.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get complaints for a specific student
  Stream<List<Complaint>> getComplaintsForStudent(String studentId) {
    return _firestore
        .collection('complaints')
        .where('student_id', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Complaint.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get resolved complaints
  Stream<List<Complaint>> getResolvedComplaints() {
    return _firestore
        .collection('complaints')
        .where('status', isEqualTo: 'resolved')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Complaint.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Assign a complaint to a moderator
  Future<void> assignComplaint(String complaintId, String moderatorId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'assigned_to': moderatorId, // Assign the complaint to the moderator
        'status': 'assigned', // Update the status to "assigned"
        // Do not update student_name, department, or year here
      });
    } catch (e) {
      throw Exception('Failed to assign complaint: $e');
    }
  }
}
