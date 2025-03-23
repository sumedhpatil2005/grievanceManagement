import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String studentId;
  final String title;
  final String description;
  final String category;
  final String status;
  final String? assignedTo; // Nullable
  final DateTime createdAt;
  final DateTime? updatedAt; // Nullable
  final String? department;
  final String? studentName; // Nullable
  final String? year;

  Complaint({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.assignedTo,
    required this.studentName,
    required this.createdAt,
    this.updatedAt,
    this.department,
    this.year,
  });

  factory Complaint.fromMap(Map<String, dynamic> data, String id) {
    return Complaint(
      studentName: data['student_name'],
      id: id,
      studentId: data['student_id'] ?? '', // Handle null
      title: data['title'] ?? '', // Handle null
      description: data['description'] ?? '', // Handle null
      category: data['category'] ?? '', // Handle null
      status: data['status'] ?? 'pending', // Handle null
      assignedTo: data['assigned_to'], // Ensure this matches Firestore
      createdAt:
          data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          data['updated_at'] != null
              ? (data['updated_at'] as Timestamp).toDate()
              : null, // Can be null
      department: data['department'], // Can be null
      year: data['year'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'student_id': studentId,
      'student_name': studentName, // Ensure this is included
      'department': department, // Ensure this is included
      'status': status,
      'assigned_to': assignedTo, // Ensure this matches Firestore
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'year': year,
    };
  }
}
