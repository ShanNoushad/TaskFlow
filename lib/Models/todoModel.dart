import 'package:cloud_firestore/cloud_firestore.dart';

class StepModel {
  final String title;
  final bool done;

  StepModel({
    required this.title,
    required this.done,
  });

  factory StepModel.fromMap(Map<String, dynamic> map) {
    return StepModel(
      title: map['title'] ?? '',
      done: map['done'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "done": done,
    };
  }
}

class ProjectModel {
  final String? id;
  final String title;
  final String description;
  final String group;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final Map<String, StepModel> steps;
  final String type;
  final DateTime createdAt;

  ProjectModel({
    this.id,
    required this.title,
    required this.description,
    required this.group,
    required this.startDate,
    required this.endDate,
    this.progress = 0.0,
    required this.steps,
    this.type = "todo",
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "group": group,
      "startDate": Timestamp.fromDate(startDate),
      "endDate": Timestamp.fromDate(endDate),
      "progress": progress,
      "steps": steps.map((key, value) => MapEntry(key, value.toMap())),
      "type": type,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map, String docId) {

    Map<String, StepModel> stepsMap = {};

    if (map["steps"] != null) {
      (map["steps"] as Map<String, dynamic>).forEach((key, value) {
        stepsMap[key] = StepModel.fromMap(
          Map<String, dynamic>.from(value),
        );
      });
    }

    return ProjectModel(
      id: docId,
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      group: map["group"] ?? "",
      startDate: (map["startDate"] as Timestamp).toDate(),
      endDate: (map["endDate"] as Timestamp).toDate(),
      progress: (map["progress"] ?? 0).toDouble(),
      steps: stepsMap,
      type: map["type"] ?? "todo",
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );


  }
  factory ProjectModel.fromDoc(DocumentSnapshot doc) {
    return ProjectModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }


}