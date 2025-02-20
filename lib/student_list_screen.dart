import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addOrEditStudent(
      {String? docId,
      String? name,
      String? studentId,
      String? major,
      String? year}) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController idController = TextEditingController(text: studentId);
    TextEditingController majorController = TextEditingController(text: major);
    TextEditingController yearController = TextEditingController(text: year);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'เพิ่มนักศึกษา' : 'แก้ไขนักศึกษา'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'ชื่อ')),
            TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'รหัสนักศึกษา')),
            TextField(
                controller: majorController,
                decoration: InputDecoration(labelText: 'สาขา')),
            TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'ชั้นปี')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('ยกเลิก')),
          TextButton(
            onPressed: () async {
              var studentData = {
                'name': nameController.text,
                'student_id': idController.text,
                'major': majorController.text,
                'year': yearController.text,
              };
              if (docId == null) {
                // เพิ่มข้อมูลใหม่
                await _firestore.collection('students').add(studentData);
              } else {
                // อัปเดตข้อมูล
                await _firestore
                    .collection('students')
                    .doc(docId)
                    .update(studentData);
              }
              Navigator.pop(context);
            },
            child: Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(String id) async {
    await _firestore.collection('students').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายชื่อนักศึกษา')),
      body: StreamBuilder(
        stream: _firestore.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var students = snapshot.data!.docs;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              return ListTile(
                title:
                    Text('${student['name']} (รหัส: ${student['student_id']})'),
                subtitle: Text(
                    'สาขา: ${student['major']} | ชั้นปี: ${student['year']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _addOrEditStudent(
                        docId: student.id,
                        name: student['name'],
                        studentId: student['student_id'],
                        major: student['major'],
                        year: student['year'],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteStudent(student.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditStudent(),
      ),
    );
  }
}
