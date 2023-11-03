import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

class StorageManagement {
  static Future<String> makeDirectory({required String dirName}) async {
    final Directory? directory = Platform.isAndroid
    ? await getExternalStorageDirectory() //FOR ANDROID
    : await getApplicationSupportDirectory(); //FOR iOS

    final formattedDirName = '/$dirName/';

    final Directory newDir =
        await Directory(directory!.path + formattedDirName).create();

    return newDir.path;
  }

  static get getAudioDir async => await makeDirectory(dirName: 'recordings');

  static String createRecordAudioPath(
          {required String dirPath, required String fileName}) =>
      """$dirPath${fileName.substring(0, min(fileName.length, 100))}_${DateTime.now()}.pcm""";
}