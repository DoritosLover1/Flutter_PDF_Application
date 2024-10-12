// ignore_for_file: use_build_context_synchronously
/*
++08.07.2024++
Bu sayfada kaçlı yapmak istediğimize bağlı olarak dinamik bir kod yazacağız.
Zaten şuanlık kaçlı olmasını sorduğumuz bir "input" yaptım.
*/
/*
09.07.2024
Daha spesifik eklemeler yapacağım, daha iyi olabilir. 
Belki birkaç fonksiyonu daha efektif yaparım.
*/
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/images_list.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:pdf/widgets.dart' as pw;

class SelectedImages extends StatefulWidget {
  const SelectedImages({super.key});

  @override
  State<SelectedImages> createState() => _SelectedImagesState();
}

Future<MainPage> comeBackMainPage() async {
  return const MainPage();
}

Future<void> pageNumberPrint(var pdf, var imagesList, int count) async {
  switch (count) {
    case 1:
      for (var i = 0; i < imagesList.imagePaths.length; i++) {
        final imageBytes =
            await File(imagesList.imagePaths.elementAt(i).path).readAsBytes();
        final pdfImage = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Expanded(child: pw.Image(pdfImage)),
                ],
              );
            },
          ),
        );
      }
      break;
    case 2:
      for (var i = 0; i < imagesList.imagePaths.length; i += 2) {
        final imageBytes =
            await File(imagesList.imagePaths.elementAt(i).path).readAsBytes();
        final pdfImage = pw.MemoryImage(imageBytes);
        pw.MemoryImage? pdfImage2;
        if (i + 1 < imagesList.imagePaths.length) {
          final imageBytes_2 =
              await File(imagesList.imagePaths.elementAt(i + 1).path)
                  .readAsBytes();
          pdfImage2 = pw.MemoryImage(imageBytes_2);
        }
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.GridView(
                crossAxisCount: 1,
                children: [
                  pw.Image(pdfImage),
                  if (pdfImage2 != null) pw.Image(pdfImage2),
                ],
              );
            },
          ),
        );
      }
      break;
    case 3:
      for (var i = 0; i < imagesList.imagePaths.length; i += 3) {
        final imageBytes =
            await File(imagesList.imagePaths.elementAt(i).path).readAsBytes();
        final pdfImage = pw.MemoryImage(imageBytes);
        pw.MemoryImage? pdfImage2;
        pw.MemoryImage? pdfImage3;
        if (i + 1 < imagesList.imagePaths.length) {
          final imageBytes_2 =
              await File(imagesList.imagePaths.elementAt(i + 1).path)
                  .readAsBytes();
          pdfImage2 = pw.MemoryImage(imageBytes_2);
        }
        if (i + 2 < imagesList.imagePaths.length) {
          final imageBytes_3 =
              await File(imagesList.imagePaths.elementAt(i + 2).path)
                  .readAsBytes();
          pdfImage3 = pw.MemoryImage(imageBytes_3);
        }
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.GridView(
                crossAxisCount: 1,
                children: [
                  pw.Image(pdfImage),
                  if (pdfImage2 != null) pw.Image(pdfImage2),
                  if (pdfImage3 != null) pw.Image(pdfImage3),
                ],
              );
            },
          ),
        );
      }
      break;
  }
}

class _SelectedImagesState extends State<SelectedImages> {
  ImagesList imagesList = ImagesList();
  late double progressValue = 0;
  late bool isExporting = false;
  late bool isDone = false;
  late int convertImageCount = 0;

  void convertImage() async {
    setState(() {
      isExporting = true;
    });

    final pathToSave = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS);
    final pdf = pw.Document();

    await pageNumberPrint(pdf, imagesList, int.parse(myNumberController.text));

    var text = myController.text;
    if (text == "") {
      text = "Belge1";
    }

    final outputFile = File('$pathToSave/$text.pdf');
    await outputFile.writeAsBytes(await pdf.save());
    MediaScanner.loadMedia(path: outputFile.path);
    setState(() {
      isDone = true;
    });
  }

  final myNumberController = TextEditingController();
  final myController = TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    myNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (!isExporting)
            ? const Text('Selected Photos')
            : const Text('PDF Making'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        onPressed: convertImage,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Text('Create PDF', style: TextStyle(fontSize: 20)),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: !isExporting,
              child: TextField(
                decoration: const InputDecoration(
                  hintText:
                      "How many photo will be in a each page of pdf(1,2,3)-maximum-",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.allow(RegExp('[1,2,3]')),
                ],
                controller: myNumberController,
              ),
            ),
            Visibility(
              visible: !isExporting,
              child: TextField(
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(hintText: "Enter PDF name"),
                  obscureText: false,
                  controller: myController),
            ),
            Visibility(
              visible: isDone,
              child: const AlertDialog(
                backgroundColor: Colors.teal,
                insetPadding: EdgeInsets.all(20),
                title: const Text('EXCELLEENNNT'),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text("It's done!"),
                      Text(
                          'Just press either "<--" if you wanna make more pdf.')
                    ],
                  ),
                ),
              ),
            ),
            const Gap(10),
            Visibility(
              visible: !isExporting,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: imagesList.imagePaths.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Image(
                      image: FileImage(
                        File(imagesList.imagePaths[index].path),
                      ),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
