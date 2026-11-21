import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:afc_training/course.dart';
import 'package:afc_training/store.dart';

void main(){
  late Directory tmp;
  late TrainingStore store;
  late CoursePackage course;
  setUp(() async {
    tmp=await Directory.systemTemp.createTemp('afc_group_test_');
    store=TrainingStore();
    await store.init(testingDatabasePath:p.join(tmp.path,'test.db'));
    course=CoursePackage.parse(File('assets/content/controls.json').readAsStringSync());
  });
  tearDown(() async {
    await store.close();
    if(await tmp.exists())await tmp.delete(recursive:true);
  });
  test('group contains independent employee records',()async{
    final g=await store.createGroup('Обучение А','Организация А');
    final s1=await store.addStudent(g,'Иван','Петров');
    final s2=await store.addStudent(g,'Анна','Смирнова');
    expect(s1,isNot(s2));
    final employees=await store.students(g);
    expect(employees.length,2);
    expect((await store.group(g))['completed_at'],isNull);
    await store.finishGroup(g);
    expect((await store.group(g))['completed_at'],isNotNull);
  });
  test('16/20 passes; 15/20 fails; results belong to selected student',()async{
    final group=await store.createGroup('Группа 1','Предприятие');
    final s1=await store.addStudent(group,'Алексей','Тестов');
    final s2=await store.addStudent(group,'Ольга','Контрольная');
    await store.finishGroup(group);
    final exam1=course.newExam(random:Random(1));
    final pass=exam1.map((q)=>q.correctIndex).toList();
    for(var i=0;i<4;i++){pass[i]=(pass[i]+1)%4;}
    await store.saveAttempt(groupId:group,studentId:s1,startedAt:DateTime.utc(2026,11,21),
      questions:exam1,answers:pass);
    final exam2=course.newExam(random:Random(2));
    final fail=exam2.map((q)=>q.correctIndex).toList();
    for(var i=0;i<5;i++){fail[i]=(fail[i]+1)%4;}
    await store.saveAttempt(groupId:group,studentId:s2,startedAt:DateTime.utc(2026,11,21),
      questions:exam2,answers:fail);
    final a1=await store.attempts(studentId:s1);
    final a2=await store.attempts(studentId:s2);
    expect(a1.length,1);
    expect(a2.length,1);
    expect(a1.first['correct'],16);
    expect(a1.first['passed'],1);
    expect(a2.first['correct'],15);
    expect(a2.first['passed'],0);
    expect(a1.first['student_id'],s1);
    expect(a2.first['student_id'],s2);
  });
  test('examination blocked before joint course completion',()async{
    final group=await store.createGroup('Незавершённая','Предприятие');
    final student=await store.addStudent(group,'Имя','Фамилия');
    final exam=course.newExam(random:Random(9));
    final answers=exam.map((q)=>q.correctIndex).toList();
    await expectLater(
      store.saveAttempt(groupId:group,studentId:student,startedAt:DateTime.now(),
        questions:exam,answers:answers),
      throwsStateError
    );
  });
  test('an attendee cannot impersonate another group in saved data',()async{
    final g1=await store.createGroup('Первая','А');
    final g2=await store.createGroup('Вторая','Б');
    final s=await store.addStudent(g1,'Имя','Фамилия');
    await store.finishGroup(g2);
    final exam=course.newExam(random:Random(9));
    await expectLater(
      store.saveAttempt(groupId:g2,studentId:s,startedAt:DateTime.now(),
        questions:exam,answers:exam.map((q)=>q.correctIndex).toList()),
      throwsStateError
    );
  });
}
