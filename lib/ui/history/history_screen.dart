import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/dialog/rename/rename_dialog.dart';
import 'package:my_deficiencies/common/utility.dart';
import 'package:my_deficiencies/data_base/chat_list_data_base.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/model/chat_gpt_d_b_model.dart';
import 'package:my_deficiencies/ui/chat/chat_screen.dart';
import 'package:my_deficiencies/ui/setting/setting_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {

    Widget historyList(int index, Map<String, dynamic> map) {
      ChatGptDbModel chatGptDbModel = ChatGptDbModel.fromJson(map);
      ChatListHistoryModel chatListHistoryModel = chatGptDbModel.message!.isNotEmpty
          ? chatGptDbModel.message!.first
          : ChatListHistoryModel(
              id: 0, // default int
              message: '',
              currentDateAndTime: '',
              isSender: false, // default bool
              isAnimation: false, // default bool
              isGpt4: false, // default bool
            );


      return GestureDetector(
        onTap: () async {
          Utility.chatHistoryList = chatGptDbModel.message!;
          Utility.isSenderId = chatGptDbModel.id;
          Utility.isNewChat = false;
          if (kDebugMode) {
            print('ChatScreen  ${await DBHelper.getData(3)}');
          }
          Get.to(ChatScreen())!.then((value) {
            if (mounted) setState(() {});
          });
        },
        child: Container(
          width: Get.width,
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          padding: EdgeInsets.only(left: 15, right: 5, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColor.btnColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview if available
              if (chatListHistoryModel.imagePath != null &&
                  chatListHistoryModel.imagePath!.isNotEmpty &&
                  File(chatListHistoryModel.imagePath!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(chatListHistoryModel.imagePath!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              if (chatListHistoryModel.imagePath != null &&
                  chatListHistoryModel.imagePath!.isNotEmpty)
                SizedBox(width: 10),

              // Text part
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(
                      title: chatGptDbModel.title ?? chatListHistoryModel.message ?? '',
                      fontSize: 14,
                      color: AppColor.white,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    appText(
                      title: chatListHistoryModel.message ?? '',
                      fontSize: 12,
                      color: AppColor.white.withOpacity(0.8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Icon(
                CupertinoIcons.right_chevron,
                size: 15,
                color: AppColor.white,
              ),
            ],
          ),
        ),
      );
    }


    return GetBuilder<LightDarkController>(
      builder: (lightDarkController) {
        return Scaffold(
          backgroundColor: AppColor.bgColor,
          appBar: AppBar(
            backgroundColor: AppColor.bgColor,
            forceMaterialTransparency: true,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                CupertinoIcons.chevron_back,
                color: AppColor.white,
              ),
            ),
            title: appText(
              title: 'My History',
              color: AppColor.white,
              fontWeight: FontWeight.w700
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(SettingScreen());
                },
                icon: Icon(
                  CupertinoIcons.settings,
                  color: AppColor.white,
                )
              ),
            ],
            centerTitle: true,
          ),
          body: FutureBuilder(
            future: DBHelper.getAllData(),
            builder: (context, snap) {
              if(!snap.hasData) {
                return Container();
              }
              if(snap.data == null) {
                return Container();
              }
              if(snap.data!.isEmpty) {
                return Container();
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snap.data!.reversed.length,
                itemBuilder: (context, index) {
                  return historyList(
                    index, snap.data!.reversed.toList()[index],
                  );
                },
              );
            }
          ),
        );
      }
    );
  }

  String cleanMarkdown(String input) {
    final regex = RegExp(r'^[--]{3,}$', multiLine: true);
    return input.replaceAll(regex, '').trim();
  }
  List<pw.Widget> convertMarkdownToWidgets(String markdown, pw.TextStyle baseStyle) {
    final lines = markdown.split('\n');
    final widgets = <pw.Widget>[];
    log('convertMarkdownToWidgets:- $markdown');
    List<List<String>>? currentTable;

    for (final line in lines) {
      final trimmed = cleanMarkdown(line.trim());
      if (trimmed.isEmpty) {
        widgets.add(pw.SizedBox(height: 8));
        continue;
      }

      // Headings
      if (trimmed.startsWith('##')) {
        if (kDebugMode) {
          print('trimmed $trimmed');
        }
        final level = trimmed.indexOf(' ');
        final text = trimmed.substring(level + 1).trim().replaceAll('##', '');
        widgets.add(
          pw.Header(
            level: level.clamp(0, 2), // Max level 2
            text: text,
            textStyle: baseStyle.copyWith(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      } else if (trimmed.startsWith('#')) {
        if (kDebugMode) {
          print('trimmed123 $trimmed');
        }
        final level = trimmed.indexOf(' ');
        final text = trimmed.substring(level + 1).trim();
        widgets.add(
          pw.Header(
            level: level.clamp(0, 2),
            text: text,
            textStyle: baseStyle.copyWith(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      }

      // Bullet list
      else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        widgets.add(
          pw.Bullet(text: trimmed.substring(2), style: baseStyle),
        );
      }
      else if (trimmed.startsWith('─────────────────────────────')) {
        widgets.add(
          pw.Divider(),
        );
      }
      // Table row (| col | col |)
      else if (trimmed.startsWith('|') && trimmed.endsWith('|')) {
        final columns = trimmed.split('|').map((e) => e.trim()).toList();
        columns.removeWhere((c) => c.isEmpty);
        columns.removeWhere((c) => c == '--');
        currentTable ??= [];
        currentTable.add(columns);
      }
      // If table is ending
      else if (currentTable != null) {
        widgets.add(
          pw.TableHelper.fromTextArray(
            headers: currentTable.first,
            data: currentTable.skip(1).toList(),
            border: pw.TableBorder.all(width: 0.5),
            headerStyle: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
            cellStyle: baseStyle,
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
          ),
        );
        currentTable = null;
        widgets.add(pw.SizedBox(height: 12));
        widgets.add(pw.Paragraph(text: trimmed, style: baseStyle));
      }
      // Bold or regular text
      else {
        String formattedText = trimmed;
        pw.TextStyle textStyle = baseStyle;

        // Bold detection (**text** or __text__)
        final boldRegex = RegExp(r'\*\*(.*?)\*\*|__(.*?)__');
        final match = boldRegex.firstMatch(formattedText);
        if (match != null) {
          formattedText = formattedText.replaceAllMapped(boldRegex, (m) => m[1] ?? m[2] ?? '');
          textStyle = baseStyle.copyWith(fontWeight: pw.FontWeight.bold);
        }

        widgets.add(pw.Paragraph(text: formattedText, style: textStyle));
      }
    }

    // Handle table if it's the last section
    if (currentTable != null) {
      widgets.add(
        pw.TableHelper.fromTextArray(
          headers: currentTable.first,
          data: currentTable.skip(1).toList(),
          border: pw.TableBorder.all(width: 0.5),
          headerStyle: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
          cellStyle: baseStyle,
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
        ),
      );
    }

    return widgets;
  }

  Future<void> exportChatToPdf(List<ChatListHistoryModel> chat, String title) async {
    final pdf = pw.Document();

    final gelasio400 = pw.Font.ttf(await rootBundle.load('assets/fonts/Gelasio-400.ttf'));
    final gelasio500 = pw.Font.ttf(await rootBundle.load('assets/fonts/Gelasio-500.ttf'));
    // final gelasio600 = pw.Font.ttf(await rootBundle.load('assets/fonts/Gelasio-600.ttf'));
    final gelasio700 = pw.Font.ttf(await rootBundle.load('assets/fonts/Gelasio-700.ttf'));
    // final font = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans.ttf'));
    // final symbola = pw.Font.ttf(await rootBundle.load('assets/fonts/Symbola.ttf'));
    final appleColorEmoji = pw.Font.ttf(await rootBundle.load('assets/fonts/AppleColorEmoji.ttf'));
    final fontEmoji = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoColorEmoji.ttf'));
    // final fallbackFont = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSansMono.ttf'));
    final segoeUIEmoji = pw.Font.ttf(await rootBundle.load('assets/fonts/Segoe UI Emoji.ttf'));
    // final unifont = pw.Font.ttf(await rootBundle.load('assets/fonts/Unifont.ttf'));

    final style = pw.TextStyle(
      font: gelasio500,
      fontBold: gelasio700,
      fontNormal: gelasio400,
      fontFallback: [appleColorEmoji, fontEmoji, segoeUIEmoji],
      fontSize: 12,
    );

    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(24),
        build: (context) {
          List<pw.Widget> widgets = [];

          for (var message in chat) {
            final role = message.isSender ? 'user' : '';
            final content = message.message;

            widgets.add(
              pw.Text(role == 'user' ? '👤 User:' : '🤖 Assistant:', style: style.copyWith(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            );
            role == 'user' ? widgets.add(
              pw.Text(content!, style: style.copyWith(fontWeight: pw.FontWeight.bold, fontSize: 15)),
            ) : widgets.addAll(convertMarkdownToWidgets(content!, style));
            widgets.add(pw.SizedBox(height: 12));
          }

          return widgets;
        },
      ),
    );

    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/${title}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    // await file.writeAsBytes(await pdf.save());

    String? outputFile = await FilePicker.platform.saveFile(
      // dialogTitle: 'Please select an output file:',
      // fileName: 'output-file.pdf',
      bytes: await pdf.save(),
      fileName: '${title}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    if (outputFile == null) {
      // User canceled the picker
      if (kDebugMode) {
        print("✅ Exported to: $outputFile");
      }
      SharePlus.instance.share(ShareParams(files: [XFile(outputFile!)]));
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${title}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    }

    // var file = await FileSaver.instance.saveFile(
    //   name: '${title}_${DateTime.now().millisecondsSinceEpoch}',
    //   fileExtension: 'pdf',
    //   mimeType: MimeType.pdf,
    //   // filePath: (await getApplicationSupportDirectory()).path,
    //   bytes: await pdf.save()
    // );
    // if (kDebugMode) {
    //   print("✅ Exported to: ${file.path}");
    // }
    // SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

}
