import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class ControlPoint {
  final String topic, good, bad, action, evidence;
  const ControlPoint(this.topic, this.good, this.bad, this.action, this.evidence);
  factory ControlPoint.fromJson(Map<String, dynamic> j) =>
      ControlPoint(j['topic'], j['good'], j['bad'], j['action'], j['evidence']);
}
class CourseSection {
  final int id;
  final String title;
  final List<ControlPoint> controls;
  const CourseSection(this.id, this.title, this.controls);
  factory CourseSection.fromJson(Map<String, dynamic> j) => CourseSection(
      j['id'], j['title'], (j['controls'] as List)
          .map((e) => ControlPoint.fromJson(Map<String,dynamic>.from(e))).toList());
}
class TrainingSlide {
  final String id, title, subtitle, imageAsset, audioAsset;
  final int sectionId, slideInSection;
  final List<String> bulletPoints;
  const TrainingSlide(this.id, this.title, this.subtitle, this.sectionId,
      this.slideInSection, this.bulletPoints, this.imageAsset, this.audioAsset);
}
class ExamQuestion {
  final String id, prompt;
  final int section;
  final List<String> options;
  const ExamQuestion(this.id, this.section, this.prompt, this.options);
}
class AskedQuestion {
  final ExamQuestion source;
  final List<String> choices;
  final int correctIndex;
  const AskedQuestion(this.source, this.choices, this.correctIndex);
  bool isCorrect(int? chosen) => chosen == correctIndex;
}
class CoursePackage {
  final String name;
  final List<CourseSection> sections;
  final Map<String,String> notes;
  const CoursePackage(this.name, this.sections, [this.notes=const {}]);
  static Future<CoursePackage> load() async {
    final course=CoursePackage.parse(await rootBundle.loadString('assets/content/controls.json'));
    final raw=jsonDecode(await rootBundle.loadString('assets/content/notes.json')) as Map<String,dynamic>;
    return CoursePackage(course.name,course.sections,raw.map((key,value)=>MapEntry(key,value.toString())));
  }
  static CoursePackage parse(String data) {
    final j = jsonDecode(data) as Map<String,dynamic>;
    final sections = (j['sections'] as List)
        .map((e) => CourseSection.fromJson(Map<String,dynamic>.from(e))).toList();
    if (sections.length != 14 || sections.any((e) => e.controls.length != 5)
        || sections.map((e) => e.id).toSet().length != 14) {
      throw const FormatException('Курс: 14 разделов и 5 тем в каждом');
    }
    return CoursePackage(j['course'], sections);
  }
  List<TrainingSlide> get slides {
    const kinds = ['Требования', 'Правильная практика',
      'Типичные нарушения', 'Практический алгоритм', 'Контроль и записи'];
    final out = <TrainingSlide>[];
    for(final section in sections) {
      for(int i=0; i<5; i++) {
        final n=i+1;
        final id=section.id.toString().padLeft(2,'0')+'_'+n.toString().padLeft(2,'0');
        final points=section.controls.map((c) => switch(i) {
          0 => c.topic+': '+c.good,
          1 => c.good,
          2 => c.bad,
          3 => c.action,
          _ => c.topic+': '+c.evidence
        }).toList();
        out.add(TrainingSlide(id,'Раздел '+section.id.toString()+'. '+section.title,
            kinds[i],section.id,n,points,'assets/slides/'+id+'.png','audio/'+id+'.mp3'));
      }
    }
    if(out.length != 70) throw StateError('Expected 70 slides');
    return out;
  }
  List<ExamQuestion> get bank {
    final list=<ExamQuestion>[];
    for(final section in sections) {
      final c=section.controls;
      for(int i=0; i<5; i++) {
        final item=c[i];
        final others=[for(int j=1; j<=3; j++) c[(i+j)%5]];
        final id=section.id.toString().padLeft(2,'0')+'-'+(i+1).toString();
        list.add(ExamQuestion(id+'-A',section.id,
            'Что соответствует безопасной практике по теме «'+item.topic+'»?',
            [item.good,...others.map((o)=>o.bad)]));
        list.add(ExamQuestion(id+'-B',section.id,
            'Какое наблюдение является нарушением в теме «'+item.topic+'»?',
            [item.bad,...others.map((o)=>o.good)]));
        list.add(ExamQuestion(id+'-C',section.id,
            'Выявлено: «'+item.bad+'». Какая коррекция наиболее подходит?',
            [item.action,...others.map((o)=>o.action)]));
        list.add(ExamQuestion(id+'-D',section.id,
            'Какая запись наиболее прямо подтверждает контроль «'+item.topic+'»?',
            [item.evidence,...others.map((o)=>o.evidence)]));
      }
    }
    final all=[for(final s in sections)
      for(final c in s.controls) (s.id,c)];
    for(int i=0;i<20;i++) {
      final (sId,c)=all[(i*3)%all.length];
      final section=sections.firstWhere((s)=>s.id==sId);
      final index=section.controls.indexOf(c);
      final others=[for(int j=1;j<=3;j++) section.controls[(index+j)%5]];
      list.add(ExamQuestion('CASE-'+(i+1).toString().padLeft(2,'0'),sId,
          'Ситуация на пищеблоке: '+c.bad+'. Какое действие выбрать прежде всего?',
          [c.action,...others.map((o)=>o.action)]));
    }
    if(list.length != 300 || list.map((q)=>q.id).toSet().length!=300) {
      throw StateError('Expected exactly 300 questions');
    }
    for(final q in list) {
      if(q.options.length!=4||q.options.toSet().length!=4) {
        throw StateError('Repeated options: '+q.id);
      }
    }
    return list;
  }
  List<AskedQuestion> newExam({Random? random}) {
    final rng=random??Random.secure();
    final selected=bank.toList()..shuffle(rng);
    return selected.take(20).map((q){
      final variants=q.options.skip(1).toList()..shuffle(rng);
      final p=rng.nextDouble();
      final pos=p<.20?0:p<.60?1:p<.80?2:3;
      variants.insert(pos,q.options.first);
      return AskedQuestion(q,variants,pos);
    }).toList();
  }
}
