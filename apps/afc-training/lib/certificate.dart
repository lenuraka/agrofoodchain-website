import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificateService {
  // No logo, watermark, synchronization, or registry placeholder on certificates.
  static Future<String> issue({
    required int attemptId,
    required String fullName,
    required String company,
    required int correct,
    required DateTime examDate,
  }) async {
    if(correct<16 || correct>20) throw ArgumentError('Сертификат возможен только после 16/20');
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final paper = pw.Document();
    final navy=PdfColor.fromInt(0xFF18324A);
    final green=PdfColor.fromInt(0xFF15966A);
    final thin=PdfColor.fromInt(0xFFD5E5DF);
    final serial='AFC-PRP2-'+attemptId.toString().padLeft(6,'0');
    paper.addPage(pw.Page(
      pageFormat:PdfPageFormat.a4.landscape,
      margin:const pw.EdgeInsets.all(27),
      build:(c)=>pw.Container(
        decoration:pw.BoxDecoration(border:pw.Border.all(color:navy,width:2)),
        padding:const pw.EdgeInsets.all(10),
        child:pw.Container(
          decoration:pw.BoxDecoration(border:pw.Border.all(color:thin,width:1)),
          padding:const pw.EdgeInsets.symmetric(horizontal:31,vertical:22),
          child:pw.Column(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
            pw.Column(children:[
              pw.Text('AGRO FOOD CHAIN',style:pw.TextStyle(font:font,fontSize:16,color:navy)),
              pw.SizedBox(height:11),
              pw.Text('СЕРТИФИКАТ',style:pw.TextStyle(font:font,fontSize:30,color:navy)),
              pw.Text('о прохождении учебного курса',
                style:pw.TextStyle(font:font,fontSize:12,color:green)),
            ]),
            pw.Column(children:[
              pw.Text('Настоящим подтверждается, что',
                style:pw.TextStyle(font:font,fontSize:12,color:navy)),
              pw.SizedBox(height:9),
              pw.Text(fullName,style:pw.TextStyle(font:font,fontSize:24,color:navy)),
              pw.SizedBox(height:4),
              pw.Text(company,style:pw.TextStyle(font:font,fontSize:12)),
              pw.SizedBox(height:14),
              pw.Text('успешно прошёл(ла) обучение по программе',
                style:pw.TextStyle(font:font,fontSize:12)),
              pw.Text('ISO 22002-2:2025',
                style:pw.TextStyle(font:font,fontSize:20,color:green)),
              pw.Text('Предварительные программы по безопасности пищевой продукции. Общественное питание',
                textAlign:pw.TextAlign.center,style:pw.TextStyle(font:font,fontSize:10)),
              pw.SizedBox(height:14),
              pw.Text('Экзамен: '+correct.toString()+' из 20 ('+(correct*5).toString()+'%)',
                style:pw.TextStyle(font:font,fontSize:14,color:green))
            ]),
            pw.Column(children:[
              pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
                pw.Text('Дата: '+examDate.day.toString().padLeft(2,'0')+'.'+
                  examDate.month.toString().padLeft(2,'0')+'.'+examDate.year.toString(),
                  style:pw.TextStyle(font:font,fontSize:10)),
                pw.Text('№ '+serial,style:pw.TextStyle(font:font,fontSize:10)),
                pw.Text('Уполномоченный представитель: _______________',
                  style:pw.TextStyle(font:font,fontSize:10))
              ]),
              pw.SizedBox(height:9),
              pw.Text('Документ подтверждает прохождение учебного курса и не является сертификатом соответствия ISO.',
                style:pw.TextStyle(font:font,fontSize:8,color:PdfColors.grey700))
            ])
          ]),
        )
      )
    ));
    final dir=await getApplicationDocumentsDirectory();
    final certs=Directory(path.join(dir.path,'certificates'));
    await certs.create(recursive:true);
    final output=File(path.join(certs.path,serial+'.pdf'));
    await output.writeAsBytes(await paper.save(),flush:true);
    return output.path;
  }
}
