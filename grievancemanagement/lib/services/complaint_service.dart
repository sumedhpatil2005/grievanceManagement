import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grievancemanagement/data/models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitComplaint(Complaint complaint) async {
    await _firestore.collection('complaints').add({
      'category': complaint.category,
      'title': complaint.title,
      'description': complaint.description,
      'student_id': complaint.studentId,
      'status': 'pending',
      'assigned_to': null,
      'created_at': Timestamp.now(),
      'updated_at': null,
    });
  }

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

  Future<void> updateComplaintStatus(String complaintId, String status) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'status': status,
      'updated_at': Timestamp.now(),
    });
  }

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

  Future<void> assignComplaint(String complaintId, String moderatorId) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'assigned_to': moderatorId,
      'status': 'assigned',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
