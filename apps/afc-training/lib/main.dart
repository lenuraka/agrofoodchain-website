import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'course.dart';
import 'store.dart';
import 'certificate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store=TrainingStore();
  await store.init();
  final course=await CoursePackage.load();
  runApp(MaterialApp(title:'AGRO FOOD CHAIN Training',debugShowCheckedModeBanner:false,
    theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF15966A)),
      appBarTheme:const AppBarTheme(backgroundColor:Color(0xFF18324A),foregroundColor:Colors.white)),
    home:TrainingApp(store:store,course:course)));
}
class TrainingApp extends StatefulWidget {
  final TrainingStore store;
  final CoursePackage course;
  const TrainingApp({super.key,required this.store,required this.course});
  @override State<TrainingApp> createState()=>_TrainingState();
}
class _TrainingState extends State<TrainingApp> {
  String screen='groups';
  int? groupId,studentId;
  String studentName='';
  Map<String,Object?>? group;
  List<Map<String,Object?>> groups=[],students=[],attempts=[];
  final player=AudioPlayer();
  int slide=0,question=0;
  late List<AskedQuestion> asked;
  List<int?> selected=[];
  late DateTime examStarted;
  bool busy=false;
  @override void initState(){super.initState();refresh();}
  @override void dispose(){player.dispose();super.dispose();}
  Future<void> refresh() async {
    groups=await widget.store.groups();
    if(groupId!=null){
      group=await widget.store.group(groupId!);
      students=await widget.store.students(groupId!);
      attempts=await widget.store.attempts(groupId:groupId!);
    }
    if(mounted)setState((){});
  }
  void notify(String message) {
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));
  }
  Future<void> createGroup() async {
    final name=TextEditingController(),company=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Создать учебную группу'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:name,decoration:const InputDecoration(labelText:'Название группы')),
        TextField(controller:company,decoration:const InputDecoration(labelText:'Предприятие'))
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Отмена')),
        FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Создать'))]));
    if(ok==true) {
      try{groupId=await widget.store.createGroup(name.text,company.text);screen='group';await refresh();}
      catch(e){notify(e.toString());}
    }
    name.dispose();company.dispose();
  }
  Future<void> addStudent() async {
    final last=TextEditingController(),first=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Добавить слушателя'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:last,decoration:const InputDecoration(labelText:'Фамилия')),
        TextField(controller:first,decoration:const InputDecoration(labelText:'Имя'))
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Отмена')),
        FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Добавить'))]));
    if(ok==true && groupId!=null){
      try{await widget.store.addStudent(groupId!,first.text,last.text);await refresh();}
      catch(e){notify(e.toString());}
    }
    last.dispose();first.dispose();
  }
  Future<void> openGroup(int id) async {
    groupId=id;screen='group';await refresh();
  }
  void openTraining() {
    slide=(group?['slide_position'] as int? ?? 0).clamp(0,69);
    screen='lessons';setState((){});
  }
  Future<void> goSlide(int next) async {
    if(next<0||next>=70)return;
    await player.stop();
    slide=next;
    await widget.store.setSlide(groupId!,next);
    if(mounted)setState((){});
  }
  Future<void> playAudio() async {
    try{
      await player.stop();
      await player.play(AssetSource(widget.course.slides[slide].audioAsset));
    }catch(e){notify('Файл озвучки не найден. После импорта уроков он появится в приложении.');}
  }
  Future<void> completeTraining() async {
    await player.stop();
    await widget.store.finishGroup(groupId!);
    screen='group';await refresh();
    notify('Групповое обучение завершено. Теперь каждый участник может сдать экзамен.');
  }
  Future<void> chooseStudent(Map<String,Object?> s) async {
    final name=(s['last_name'] as String)+' '+(s['first_name'] as String);
    final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Подтверждение слушателя'),
      content:Text('Выбран участник: '+name+'.\n\nЭкзамен будет записан на его имя. Подтвердите выбор.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Отмена')),
        FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Начать экзамен'))]));
    if(yes!=true)return;
    studentId=s['id'] as int;studentName=name;
    asked=widget.course.newExam();
    selected=List<int?>.filled(20,null);
    question=0;examStarted=DateTime.now();
    screen='exam';setState((){});
  }
  Future<void> finishExam() async {
    if(busy)return;
    final empty=selected.where((v)=>v==null).length;
    final confirm=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Завершить экзамен?'),
      content:Text(empty==0?'Все 20 ответов будут сохранены на имя '+studentName:
        'Без ответа осталось '+empty.toString()+'. Они считаются неправильными.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Продолжить')),
        FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Сохранить результат'))]));
    if(confirm!=true)return;
    setState(()=>busy=true);
    try{
      final attemptId=await widget.store.saveAttempt(groupId:groupId!,studentId:studentId!,
        startedAt:examStarted,questions:asked,answers:selected);
      final correct=List.generate(20,(i)=>asked[i].isCorrect(selected[i]))
          .where((v)=>v).length;
      var certificateStatus='';
      if(correct>=16){
        try{
          final nameOfCompany=(await widget.store.group(groupId!))['company'] as String;
          final pdf=await CertificateService.issue(attemptId:attemptId,
            fullName:studentName,company:nameOfCompany,correct:correct,examDate:DateTime.now());
          certificateStatus='PDF сохранён у администратора: '+pdf;
        }catch(e){certificateStatus='Не удалось создать PDF: '+e.toString();}
      }
      if(mounted)await showDialog<void>(context:context,builder:(c)=>AlertDialog(
        title:Text(correct>=16?'Экзамен сдан':'Экзамен не сдан'),
        content:Column(mainAxisSize:MainAxisSize.min,children:[
          Text(studentName,style:const TextStyle(fontSize:18)),
          Text(correct.toString()+' из 20 · '+(correct*5).toString()+'%',
            style:TextStyle(fontSize:28,fontWeight:FontWeight.bold,
              color:correct>=16?Colors.green:Colors.deepOrange)),
          const Text('Проходной результат: 16 из 20 (80%)'),
          if(certificateStatus.isNotEmpty) SelectableText(certificateStatus)
        ]),
        actions:[FilledButton(onPressed:()=>Navigator.pop(c),child:const Text('Закрыть'))]));
      screen='group';await refresh();
    }catch(e){notify('Ошибка при сохранении: '+e.toString());}
    if(mounted)setState(()=>busy=false);
  }
  Future<void> exportCsv() async {
    try{
      final path=await widget.store.exportCsv();
      if(mounted)await showDialog<void>(context:context,builder:(c)=>AlertDialog(
        title:const Text('Результаты экспортированы'),
        content:SelectableText('CSV-файл сохранён на вашем устройстве:\n'+path),
        actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('ОК'))]));
    }catch(e){notify(e.toString());}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(screen=='exam'?'Экзамен: '+studentName:
      screen=='lessons'?'Совместное обучение · '+(slide+1).toString()+'/70':
      'AGRO FOOD CHAIN · Обучение'),actions:[
        if(screen!='groups')IconButton(onPressed:()async{
          await player.stop();screen=screen=='exam'?'group':'groups';await refresh();
        },icon:const Icon(Icons.home_outlined),tooltip:'К группам')
      ]),
    body:Padding(padding:const EdgeInsets.all(18),child:switch(screen){
      'groups'=>groupsPage(),
      'group'=>groupPage(),
      'lessons'=>lessonPage(),
      'exam'=>examPage(),
      _=>const SizedBox()
    }),
  );
  Widget groupsPage()=>Column(children:[
    Card(color:const Color(0xFF18324A),child:Padding(padding:const EdgeInsets.all(22),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Text('ISO 22002-2:2025',style:TextStyle(color:Colors.white,fontSize:29,fontWeight:FontWeight.bold)),
        const Text('Групповое обучение и персональные экзамены',style:TextStyle(color:Colors.white70)),
        const SizedBox(height:10),
        const Text('70 слайдов · 300 вопросов · случайные 20 · зачёт 80%',
          style:TextStyle(color:Color(0xFFB5EAD9)))
      ]))),
    Row(children:[
      Expanded(child:FilledButton.icon(onPressed:createGroup,icon:const Icon(Icons.group_add),
        label:const Text('Новая группа'))),
      const SizedBox(width:8),
      OutlinedButton.icon(onPressed:exportCsv,icon:const Icon(Icons.table_view),
        label:const Text('Результаты CSV'))
    ]),
    const SizedBox(height:12),
    Expanded(child:groups.isEmpty?const Center(child:Text('Создайте группу и добавьте участников.')):
      ListView(children:groups.map((g)=>Card(child:ListTile(
        title:Text(g['title'] as String),subtitle:Text(g['company'] as String),
        trailing:Icon(g['completed_at']==null?Icons.play_circle_outline:Icons.check_circle_outline),
        onTap:()=>openGroup(g['id'] as int)))).toList()))
  ]);
  Widget groupPage(){
    if(group==null)return const Center(child:CircularProgressIndicator());
    final finished=group!['completed_at']!=null;
    return Column(children:[
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
        crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text(group!['title'] as String,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
        Text(group!['company'] as String),
        const SizedBox(height:12),
        Wrap(spacing:8,children:[
          FilledButton.icon(onPressed:openTraining,icon:const Icon(Icons.play_arrow),
            label:Text(finished?'Повторить курс':'Совместный просмотр 70 слайдов')),
          OutlinedButton.icon(onPressed:addStudent,icon:const Icon(Icons.person_add),
            label:const Text('Добавить участника'))]),
        const SizedBox(height:8),
        Text(finished?'Совместное обучение завершено. По очереди выбирайте участника для экзамена.':
          'Сначала пройдите все слайды вместе. Экзамены откроются после завершения курса.'),
        ]))),
      const SizedBox(height:8),
      Expanded(child:students.isEmpty?const Center(child:Text('Список слушателей пуст.')):
        ListView(children:students.map((s){
          final id=s['id'] as int;
          final own=attempts.where((a)=>a['student_id']==id).toList();
          return Card(child:ListTile(
            leading:const Icon(Icons.person_outline),
            title:Text((s['last_name'] as String)+' '+(s['first_name'] as String)),
            subtitle:Text(own.isEmpty?'Экзамен не сдавался':
              'Попыток: '+own.length.toString()+' · '+
              (own.any((a)=>a['passed']==1)?'есть успешная':'не сдан')),
            trailing:FilledButton.tonal(onPressed:finished?()=>chooseStudent(s):null,
              child:const Text('Сдать экзамен'))));
        }).toList())),
      if(attempts.isNotEmpty)ExpansionTile(title:Text('История экзаменов ('+attempts.length.toString()+')'),
        children:attempts.take(12).map((a)=>ListTile(
          title:Text((a['last_name'] as String)+' '+(a['first_name'] as String)),
          subtitle:Text(a['correct'].toString()+'/20 · '+a['finished_at'].toString()),
          trailing:Text(a['passed']==1?'Сдан':'Не сдан'))).toList())
    ]);
  }
  Widget lessonPage(){
    final s=widget.course.slides[slide];
    return Column(children:[
      LinearProgressIndicator(value:(slide+1)/70),
      const SizedBox(height:10),
      Text(s.title,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      Text(s.subtitle,style:const TextStyle(fontSize:17,color:Color(0xFF15966A))),
      const SizedBox(height:12),
      Expanded(child:SingleChildScrollView(child:Column(children:[
        ConstrainedBox(constraints:const BoxConstraints(maxHeight:390),
          child:AspectRatio(aspectRatio:16/9,child:Image.asset(s.imageAsset,
            fit:BoxFit.contain,errorBuilder:(c,e,trace)=>Card(child:Padding(
              padding:const EdgeInsets.all(16),child:ListView(children:[
                const Text('Текстовое содержание урока',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
                const SizedBox(height:10),
                ...s.bulletPoints.map((v)=>Padding(padding:const EdgeInsets.only(bottom:8),
                  child:Text('• '+v,style:const TextStyle(fontSize:15))))
              ])))))),
        const SizedBox(height:8),
        Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Основные тезисы',style:TextStyle(fontWeight:FontWeight.bold)),
          ...s.bulletPoints.take(3).map((v)=>Text('• '+v))])))
      ]))),
      Row(children:[
        OutlinedButton(onPressed:slide>0?()=>goSlide(slide-1):null,child:const Text('Назад')),
        const Spacer(),
        OutlinedButton.icon(onPressed:playAudio,icon:const Icon(Icons.volume_up),
          label:const Text('Озвучка')),
        const SizedBox(width:10),
        FilledButton(onPressed:slide==69?completeTraining:()=>goSlide(slide+1),
          child:Text(slide==69?'Завершить обучение':'Далее'))
      ])
    ]);
  }
  Widget examPage(){
    final q=asked[question];
    return Column(children:[
      Row(children:[
        Text('Вопрос '+(question+1).toString()+'/20',
          style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
        const Spacer(),
        Text('Отвечено '+selected.where((x)=>x!=null).length.toString()+'/20')
      ]),
      LinearProgressIndicator(value:(question+1)/20),
      const SizedBox(height:20),
      Align(alignment:Alignment.centerLeft,child:Text(q.source.prompt,
        style:const TextStyle(fontSize:21,fontWeight:FontWeight.w600))),
      const SizedBox(height:15),
      Expanded(child:ListView.builder(itemCount:4,itemBuilder:(context,i)=>Card(
        child:RadioListTile<int>(value:i,groupValue:selected[question],
          onChanged:busy?null:(v)=>setState(()=>selected[question]=v),
          title:Text((i+1).toString()+'. '+q.choices[i]))))),
      Row(children:[
        OutlinedButton(onPressed:question>0&&!busy?()=>setState(()=>question--):null,
          child:const Text('Назад')),
        const Spacer(),
        FilledButton(onPressed:busy?null:(question==19?finishExam:
          ()=>setState(()=>question++)),
          child:Text(question==19?'Завершить экзамен':'Следующий вопрос'))
      ])
    ]);
  }
}
