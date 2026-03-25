import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/todoModel.dart';
import '../Service/pojectService.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<TextEditingController> stepControllers = [TextEditingController()];

  String selectedGroup = "Work";
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;

  final List<String> groups = [
    "Work",
    "Study",
    "Personal",
    "Fitness",
    "Finance",
  ];

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    for (var c in stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> saveProject() async {
    if (_uid == null) {
      _showSnack("Not logged in");
      return;
    }
    if (nameController.text.trim().isEmpty) {
      _showSnack("Enter project name");
      return;
    }
    if (startDate == null || endDate == null) {
      _showSnack("Select start and end dates");
      return;
    }
    if (endDate!.isBefore(startDate!)) {
      _showSnack("End date must be after start date");
      return;
    }

    setState(() => isLoading = true);

    try {
      final Map<String, StepModel> steps = {};
      for (int i = 0; i < stepControllers.length; i++) {
        final text = stepControllers[i].text.trim();
        if (text.isNotEmpty) {
          steps["step${i + 1}"] = StepModel(title: text, done: false);
        }
      }

      final project = ProjectModel(
        title: nameController.text.trim(),
        description: descriptionController.text.trim(),
        group: selectedGroup,
        startDate: startDate!,
        endDate: endDate!,
        steps: steps,
      );

      await ProjectService().addProject(project: project);

      _showSnack("Project added successfully!");
      Navigator.pop(context);
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return "${date.day}/${date.month}/${date.year}";
  }

  String getInitials() {
    final text = nameController.text.trim();
    if (text.isEmpty) return "PR";
    final words = text.split(" ");
    if (words.length == 1) return words[0][0].toUpperCase();
    return words[0][0].toUpperCase() + words[1][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          "Add Project",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownTile(colorScheme),
            const SizedBox(height: 14),
            _buildTextField(
              controller: nameController,
              label: "Project Name",
              hint: "Grocery Shopping App",
              colorScheme: colorScheme,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: descriptionController,
              label: "Description",
              hint: "Write project description...",
              maxLines: 4,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 14),
            _buildStepsSection(colorScheme),
            const SizedBox(height: 14),
            _buildDateTile(
              icon: Icons.calendar_month,
              title: "Start Date",
              value: formatDate(startDate),
              onTap: () => pickDate(true),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 14),
            _buildDateTile(
              icon: Icons.calendar_month,
              title: "End Date",
              value: formatDate(endDate),
              onTap: () => pickDate(false),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 14),
            _buildLogoTile(colorScheme),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProject,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Add Project",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ColorScheme colorScheme,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGroup,
        decoration: const InputDecoration(border: InputBorder.none),
        items: groups
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) => setState(() => selectedGroup = value!),
      ),
    );
  }

  Widget _buildDateTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6))),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Project Steps",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          ...List.generate(stepControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stepControllers[index],
                      decoration: InputDecoration(
                        hintText: "Step ${index + 1}",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      if (stepControllers.length > 1) {
                        setState(() => stepControllers.removeAt(index));
                      }
                    },
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(
                    () => stepControllers.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: const Text("Add Step"),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoTile(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primary,
            child: Text(
              getInitials(),
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text("Project Logo", style: GoogleFonts.poppins()),
          const Spacer(),
          OutlinedButton(
            onPressed: () => setState(() {}),
            child: Text("Auto",
                style: GoogleFonts.poppins(
                    fontSize: 12, color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}