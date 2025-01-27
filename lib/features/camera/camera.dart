import 'dart:convert';
import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cross_file/cross_file.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  Future<String> sendToGemini(File imageFile, String prompt) async {
    const apiUrl = 'https://gemini-api.example.com/generate-keyword'; // Replace with the actual Gemini API endpoint
    const apiKey = 'your_api_key'; // Replace with your API key

    final dio = Dio();

    try {
      // Convert image to base64
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gemini-1.5-flash-latest',
          'content': [
            {
              'type': 'text',
              'data': prompt,
            },
            {
              'type': 'image',
              'data': base64Image,
            }
          ],
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['keyword'];
      } else {
        throw Exception('Failed to get keyword: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      debugPrint('Dio Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CameraAwesomeBuilder.awesome(
          onMediaCaptureEvent: (event) async {
            if (event.status == MediaCaptureStatus.success && event.isPicture) {
              event.captureRequest.when(
                single: (single) async {
                  final file = single.file;
                  if (file != null) {
                    const prompt = 'Analyze this image and suggest a one keyword for similar images.';

                    try {
                      final keyword = await sendToGemini(File(file.path), prompt);
                      debugPrint('Keyword for search: $keyword');
                    } catch (e) {
                      debugPrint('Error: $e');
                    }
                  }
                },
              );
            }
          },
          saveConfig: SaveConfig.photoAndVideo(
            initialCaptureMode: CaptureMode.photo,
            photoPathBuilder: (sensors) async {
              final Directory extDir = await getTemporaryDirectory();
              final testDir = await Directory(
                '${extDir.path}/camerawesome',
              ).create(recursive: true);
              if (sensors.length == 1) {
                final String filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                return SingleCaptureRequest(filePath, sensors.first);
              }
              // Separate pictures taken with front and back camera
              return MultipleCaptureRequest(
                {
                  for (final sensor in sensors)
                    sensor:
                        '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
                },
              );
            },
            videoOptions: VideoOptions(
              enableAudio: true,
              ios: CupertinoVideoOptions(
                fps: 10,
              ),
              android: AndroidVideoOptions(
                bitrate: 6000000,
                fallbackStrategy: QualityFallbackStrategy.lower,
              ),
            ),
            exifPreferences: ExifPreferences(saveGPSLocation: true),
          ),
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.back),
            flashMode: FlashMode.auto,
            aspectRatio: CameraAspectRatios.ratio_4_3,
            zoom: 0.0,
          ),
          enablePhysicalButton: true,
          // filter: AwesomeFilter.AddictiveRed,
          previewAlignment: Alignment.center,
          previewFit: CameraPreviewFit.contain,
          onMediaTap: (mediaCapture) {
            mediaCapture.captureRequest.when(
              single: (single) {
                debugPrint('single: ${single.file?.path}');
                single.file?.open();
              },
              multiple: (multiple) {
                multiple.fileBySensor.forEach((key, value) {
                  debugPrint('multiple file taken: $key ${value?.path}');
                  value?.open();
                });
              },
            );
          },
          availableFilters: awesomePresetFiltersList,
        ),
      ),
    );
  }
}

Future<String> path(CaptureMode captureMode) async {
  final Directory extDir = await getTemporaryDirectory();
  final testDir = await Directory('${extDir.path}/test').create(recursive: true);
  final String fileExtension = captureMode == CaptureMode.photo ? 'jpg' : 'mp4';
  final String filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
  return filePath;
}

extension XfileOpen on XFile {
  Future<void> open() async {
    final spath = this.path;
    await OpenFile.open(spath);
  }
}
