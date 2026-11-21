import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:afc_training/course.dart';

void main() {
  late CoursePackage course;
  setUpAll(() {
    final text=File('assets/content/controls.json').readAsStringSync();
    course=CoursePackage.parse(text);
  });
  test('14 sections, five slides each, no sixth slide', () {
    expect(course.sections.length,14);
    expect(course.slides.length,70);
    for(final s in course.sections) {
      final part=course.slides.where((x)=>x.sectionId==s.id);
      expect(part.length,5);
      expect(part.any((x)=>x.slideInSection==6),isFalse);
    }
  });
  test('all 70 actual source slide texts and speaker notes loaded', () {
    final text=File('assets/content/original_slides.json').readAsStringSync();
    final originals=CoursePackage.parseOriginalSlides(text);
    expect(originals.length,70);
    for(final slide in course.slides){
      final original=originals[slide.id];
      expect(original,isNotNull,reason:slide.id);
      expect(original!.content.length,greaterThan(100));
      expect(original.narration.length,greaterThan(40));
      expect(original.slide,lessThanOrEqualTo(5));
    }
    expect(originals.containsKey('10_06'),isFalse);
    expect(originals['04_01']!.content,contains('Конструкция'));
    expect(originals['17_05']!.content,contains('РАЗДЕЛ 17'));
  });

  test('300 unique four-choice questions', () {
    final bank=course.bank;
    expect(bank.length,300);
    expect(bank.map((q)=>q.id).toSet().length,300);
    for(final q in bank){
      expect(q.options.length,4);
      expect(q.options.toSet().length,4);
    }
  });
  test('20 unique random questions and correct answers after shuffling', () {
    for(int seed=0;seed<15;seed++){
      final quiz=course.newExam(random:Random(seed));
      expect(quiz.length,20);
      expect(quiz.map((q)=>q.source.id).toSet().length,20);
      for(final q in quiz) {
        expect(q.choices.length,4);
        expect(q.choices[q.correctIndex],q.source.options.first);
        expect(q.isCorrect(q.correctIndex),true);
        expect(q.isCorrect((q.correctIndex+1)%4),false);
      }
    }
  });
  test('the second position is statistically preferred, not fixed', () {
    final counts=[0,0,0,0];
    for(int seed=0;seed<200;seed++){
      for(final q in course.newExam(random:Random(seed))){
        counts[q.correctIndex]++;
      }
    }
    expect(counts[1],greaterThan(counts[0]));
    expect(counts[1],greaterThan(counts[2]));
    expect(counts[1],greaterThan(counts[3]));
    expect(counts[0],greaterThan(0));
    expect(counts[2],greaterThan(0));
    expect(counts[3],greaterThan(0));
  });
}
