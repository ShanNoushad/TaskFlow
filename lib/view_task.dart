import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectDetails extends StatefulWidget {
  final String userId;
  final String projectId;

  const ProjectDetails({
    super.key,
    required this.userId,
    required this.projectId,
  });

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {

  /// UPDATE PROGRESS
  Future<void> updateProgress(DocumentSnapshot doc) async {

    Map steps = doc["steps"] ?? {};

    int total = steps.length;
    int done = 0;

    steps.forEach((key, value) {
      if (value is Map && value["done"] == true) {
        done++;
      }
    });

    double progress = total == 0 ? 0 : done / total;

    await FirebaseFirestore.instance
        .collection("students")
        .doc(widget.userId)
        .collection("main_projects")
        .doc(widget.projectId)
        .update({
      "progress": progress
    });
  }

  /// DELETE PROJECT
  Future<void> deleteProject() async {

    await FirebaseFirestore.instance
        .collection("students")
        .doc(widget.userId)
        .collection("main_projects")
        .doc(widget.projectId)
        .delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Project"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,

        actions: [

          /// SHOW ALL PROJECTS
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          /// DELETE PROJECT
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {

              showDialog(
                context: context,
                builder: (context) {

                  return AlertDialog(
                    title: const Text("Delete Project"),
                    content: const Text(
                        "Are you sure you want to delete this project?"),

                    actions: [

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          deleteProject();
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(

        stream: FirebaseFirestore.instance
            .collection("students")
            .doc(widget.userId)
            .collection("main_projects")
            .doc(widget.projectId)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!;
          Map steps = data["steps"] ?? {};
          double progress = (data["progress"] ?? 0).toDouble();

          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// PROJECT NAME
                Text(
                  data["title"] ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// DESCRIPTION
                Text(
                  data["description"] ?? "",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                /// PROGRESS TEXT
                Text(
                  "Progress ${(progress * 100).toInt()}%",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                /// PROGRESS BAR
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 25),

                /// TASK TITLE
                Text(
                  "Project Tasks",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                /// TASK LIST
                Expanded(
                  child: ListView(
                    children: steps.entries.map<Widget>((step) {

                      String key = step.key;
                      var value = step.value;

                      String title = "";
                      bool done = false;

                      if (value is String) {
                        title = value;
                      }
                      else if (value is Map) {
                        title = value["title"] ?? "";
                        done = value["done"] ?? false;
                      }

                      return CheckboxListTile(
                        value: done,

                        onChanged: (checked) async {

                          await FirebaseFirestore.instance
                              .collection("students")
                              .doc(widget.userId)
                              .collection("main_projects")
                              .doc(widget.projectId)
                              .update({
                            "steps.$key": {
                              "title": title,
                              "done": checked
                            }
                          });

                          updateProgress(data);
                        },

                        title: Text(
                          title,
                          style: GoogleFonts.poppins(
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        controlAffinity:
                        ListTileControlAffinity.leading,
                      );

                    }).toList(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}