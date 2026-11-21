import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'course.dart';

class TrainingStore {
  late final Database db;
  Future<void> init({String? testingDatabasePath}) async {
    if(!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final String databasePath;
    if(testingDatabasePath!=null){
      databasePath=testingDatabasePath;
    }else{
      final dir=await getApplicationDocumentsDirectory();
      await dir.create(recursive:true);
      databasePath=p.join(dir.path,'afc_training_v2.db');
    }
    db=await openDatabase(databasePath,version:1,
      onCreate:(d,v) async {
        await d.execute('CREATE TABLE groups(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, company TEXT NOT NULL, created_at TEXT NOT NULL, completed_at TEXT, slide_position INTEGER NOT NULL DEFAULT 0)');
        await d.execute('CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER NOT NULL, first_name TEXT NOT NULL, last_name TEXT NOT NULL, created_at TEXT NOT NULL, FOREIGN KEY(group_id) REFERENCES groups(id))');
        await d.execute('CREATE TABLE attempts(id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER NOT NULL, student_id INTEGER NOT NULL, started_at TEXT NOT NULL, finished_at TEXT NOT NULL, correct INTEGER NOT NULL, total INTEGER NOT NULL, passed INTEGER NOT NULL, details TEXT NOT NULL, FOREIGN KEY(group_id) REFERENCES groups(id), FOREIGN KEY(student_id) REFERENCES students(id))');
        await d.execute('CREATE INDEX attempts_student ON attempts(student_id)');
        await d.execute('CREATE INDEX attempts_group ON attempts(group_id)');
      });
  }
  Future<int> createGroup(String title,String company) async {
    if(title.trim().isEmpty||company.trim().isEmpty) throw ArgumentError('Укажите группу и предприятие');
    return db.insert('groups',{'title':title.trim(),'company':company.trim(),
      'created_at':DateTime.now().toUtc().toIso8601String(),'slide_position':0});
  }
  Future<int> addStudent(int groupId,String first,String last) async {
    if(first.trim().isEmpty || last.trim().isEmpty) throw ArgumentError('Укажите имя и фамилию');
    return db.insert('students',{'group_id':groupId,
      'first_name':first.trim(),'last_name':last.trim(),
      'created_at':DateTime.now().toUtc().toIso8601String()});
  }
  Future<List<Map<String,Object?>>> groups() async =>db.query('groups',orderBy:'id DESC');
  Future<Map<String,Object?>> group(int id) async {
    final r=await db.query('groups',where:'id=?',whereArgs:[id],limit:1);
    if(r.isEmpty) throw StateError('Группа не найдена');
    return r.first;
  }
  Future<List<Map<String,Object?>>> students(int groupId) async =>
      db.query('students',where:'group_id=?',whereArgs:[groupId],orderBy:'last_name, first_name, id');
  Future<void> setSlide(int groupId,int zeroIndex) async =>
      db.update('groups',{'slide_position':zeroIndex},where:'id=?',whereArgs:[groupId]);
  Future<void> finishGroup(int groupId) async =>
      db.update('groups',{'slide_position':69,
        'completed_at':DateTime.now().toUtc().toIso8601String()},where:'id=?',whereArgs:[groupId]);
  Future<int> saveAttempt({
    required int groupId,required int studentId,required DateTime startedAt,
    required List<AskedQuestion> questions,required List<int?> answers
  }) async {
    if(questions.length!=20 || answers.length!=20) throw StateError('Нужны 20 вопросов и ответов');
    final g=await group(groupId);
    if(g['completed_at']==null) throw StateError('Групповой курс ещё не завершён');
    final owned=await db.query('students',where:'id=? AND group_id=?',whereArgs:[studentId,groupId],limit:1);
    if(owned.isEmpty) throw StateError('Участник не относится к группе');
    final correct=List.generate(20,(i)=>questions[i].isCorrect(answers[i])).where((v)=>v).length;
    final details=List.generate(20,(i){
      final q=questions[i];
      return {'id':q.source.id,'section':q.source.section,'question':q.source.prompt,
        'options':q.choices,'correct_index':q.correctIndex,'selected_index':answers[i],
        'correct':q.isCorrect(answers[i])};
    });
    return db.insert('attempts',{'group_id':groupId,'student_id':studentId,
      'started_at':startedAt.toUtc().toIso8601String(),
      'finished_at':DateTime.now().toUtc().toIso8601String(),
      'correct':correct,'total':20,'passed':correct>=16?1:0,'details':jsonEncode(details)});
  }
  Future<List<Map<String,Object?>>> attempts({int? groupId,int? studentId}) async {
    final where=<String>[];
    final args=<Object>[];
    if(groupId!=null){where.add('a.group_id=?');args.add(groupId);}
    if(studentId!=null){where.add('a.student_id=?');args.add(studentId);}
    final condition=where.isEmpty?'':' WHERE '+where.join(' AND ');
    final sql='SELECT a.*,s.first_name,s.last_name,g.title AS group_title,g.company '
      +'FROM attempts a INNER JOIN students s ON s.id=a.student_id '
      +'INNER JOIN groups g ON g.id=a.group_id'+condition+' ORDER BY a.id DESC';
    return db.rawQuery(sql,args);
  }
  Future<String> exportCsv() async {
    final data=await attempts();
    String cell(Object? obj)=>'"'+(obj??'').toString().replaceAll('"','""')+'"';
    final rows=<String>[
      ['Попытка','Группа','Компания','Фамилия','Имя','Дата UTC','Верных','Всего','Результат %','Зачёт'].map(cell).join(';'),
      ...data.map((r)=>[r['id'],r['group_title'],r['company'],r['last_name'],r['first_name'],
        r['finished_at'],r['correct'],r['total'],
        ((r['correct'] as int)*100/(r['total'] as int)).round(),
        (r['passed']==1?'СДАН':'НЕ СДАН')].map(cell).join(';'))
    ];
    final dir=await getApplicationDocumentsDirectory();
    final file=File(p.join(dir.path,'afc_results_'+DateTime.now().millisecondsSinceEpoch.toString()+'.csv'));
    await file.writeAsString('\uFEFF'+rows.join('\r\n'),encoding:utf8,flush:true);
    return file.path;
  }
  Future<void> close() async =>db.close();
}
