import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/todoModel.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference _projectsRef(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('projects');

  Future<void> addProject({required ProjectModel project}) async {
    if (_uid == null) throw Exception("Not logged in");
    await _projectsRef(_uid!).add(project.toMap());
  }

  Stream<List<ProjectModel>> getProjects() {
    if (_uid == null) return const Stream.empty();
    return _projectsRef(_uid!).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProjectModel.fromDoc(doc)).toList());
  }

  Future<void> updateStep({
    required String projectId,
    required String stepKey,
    required bool value,
  }) async {
    if (_uid == null) throw Exception("Not logged in");

    final ref = _projectsRef(_uid!).doc(projectId);

    // 1. Toggle the step
    await ref.update({
      "steps.$stepKey.done": value,
    });

    // 2. Fetch the latest doc to recompute progress
    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>;
    final steps = data["steps"] as Map<String, dynamic>? ?? {};

    final total = steps.length;
    final done = steps.values
        .where((s) => (s as Map<String, dynamic>)["done"] == true)
        .length;

    final newProgress = total == 0 ? 0.0 : done / total;
    await ref.update({"progress": newProgress});
  }

  Future<void> deleteProject(String projectId) async {
    if (_uid == null) throw Exception("Not logged in");
    await _projectsRef(_uid!).doc(projectId).delete();
  }


  Future<int> getProjectNotCompleteCount() async {
    if (_uid == null) throw Exception("Not logged in");
    final snapshot = await _projectsRef(_uid!).where("progress",isNotEqualTo: 1).get();
    return snapshot.docs.length;
  }
  
  Future<int> getProjectCompletedCount() async {
    if (_uid == null) throw Exception("Not logged in");
    final snapshot = await _projectsRef(_uid!).where("progress",isEqualTo: 1).get();
    return snapshot.docs.length;
  }
  
  

}