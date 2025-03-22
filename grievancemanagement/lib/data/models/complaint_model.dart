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
  });

  factory Complaint.fromMap(Map<String, dynamic> data, String id) {
    return Complaint(
      studentName: data['studentName'],
      id: id,
      studentId: data['student_id'] ?? '', // Handle null
      title: data['title'] ?? '', // Handle null
      description: data['description'] ?? '', // Handle null
      category: data['category'] ?? '', // Handle null
      status: data['status'] ?? 'pending', // Handle null
      assignedTo: data['assignedTo'], // Can be null
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null, // Can be null
      department: data['department'], // Can be null
    );
  }
}
