// import 'dart:io';

// import 'package:ademlync_cloud/ademlync_cloud.dart';
// import 'package:ademlync_device/ademlync_device.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_test/flutter_test.dart';

// const _sn = '00000000';
// const _logType = LogType.daily;

// void main() {
//   final manager = CloudManager();

//   List<String>? logs;
//   List<String>? localLogs;
//   List<String>? paths;

//   group('Log - ', () {
//     // test('All logs', () async {
//     //   try {
//     //     logs = await manager.fetchAllLogs(_logType, _sn);
//     //     if (kDebugMode) print(logs);
//     //   } catch (e) {
//     //     if (kDebugMode) print(e);
//     //   }
//     // });

//     // test('Download', () async {
//     //   try {
//     //     final log = logs!.first;
//     //     await manager.downloadLogs({log});
//     //   } catch (e) {
//     //     if (kDebugMode) print(e);
//     //   }
//     // });

//     // test('Retrieve local', () async {
//     //   try {
//     //     final localDirectory = true
//     //         ? '${(await getApplicationDocumentsDirectory()).path}/'
//     //         : '/storage/emulated/0/Ademlync/';

//     //     String path = localDirectory;
//     //     path += 'Daily-Log/';
//     //     final data = Directory(path).listSync();
//     //     localLogs = data.map((e) => e.path).toList();
//     //     if (kDebugMode) print(localLogs);
//     //   } catch (e) {
//     //     if (kDebugMode) print(e);
//     //   }
//     // });

//     // test('Upload path', () async {
//     //   try {
//     //     paths = await manager.fetchUploadLogsFolderPaths(_logType);
//     //     if (kDebugMode) print(paths);
//     //   } catch (e) {
//     //     if (kDebugMode) print(e);
//     //   }
//     // });

//     // test('Upload', () async {
//     //   try {
//     //     final log = localLogs!.firstWhere((e) => e.split('.').last == 'xlsx');
//     //     final path = paths!.first;
//     //     await manager.uploadLogs(
//     //       _sn,
//     //       path,
//     //       log,
//     //       log.split('/').last,
//     //       ExportLogFmt.excel,
//     //     );
//     //   } catch (e) {
//     //     if (kDebugMode) print(e);
//     //   }
//     // });
//   });
// }
