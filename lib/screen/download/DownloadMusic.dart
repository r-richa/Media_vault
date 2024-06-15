import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../player/SamplePlayer.dart';

class DownloadsMusic extends StatefulWidget {
  const DownloadsMusic({super.key});

  @override
  _DownloadsMusicState createState() => _DownloadsMusicState();
}

class _DownloadsMusicState extends State<DownloadsMusic> {
  List<Map<String, String>> downloadedFiles = [];
  List<Map<String, String>> downloadedMusic = [];


  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    // Retrieve the directory where the downloaded files are stored
    Directory directory = await getApplicationDocumentsDirectory();

    // Get all files in the directory
    List<FileSystemEntity> files = directory.listSync();

    // Filter out non-file entities (like directories)
    downloadedFiles = files.whereType<File>().map((file){
      String fileName = file.path.split('/').last;
      String fileId = fileName.split('.').first;
      String thumbnailPath = '${directory.path}/$fileId.jpg';
      return {
        'filePath': file.path,
        'thumbnailPath': File(thumbnailPath).existsSync() ? thumbnailPath : '',
        'fileName': fileName,
      };
    }).toList();





    downloadedMusic = downloadedFiles.where((file) => file['filePath']!.toLowerCase().endsWith('.mp3')).toList();


    setState(() {});
  }

  Future<void> _deleteAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          downloadedMusic.removeWhere((file) => file['filePath'] == filePath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio deleted successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio not found!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete audio: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        itemCount: downloadedMusic.length,
        itemBuilder: (context, index) {
          var fileInfo = downloadedMusic[index];
          return ListTile(
            leading: fileInfo['thumbnailPath']!.isNotEmpty
                ? Image.file(File(fileInfo['thumbnailPath']!))
                : null,
            title: Text(fileInfo['fileName']!),
            subtitle: Text(
              'Size: ${(File(fileInfo['filePath']!).lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    File file = File(fileInfo['filePath']!);
                    print(file);
                    if (await file.exists()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SamplePlayer(file: file),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Audio not found!'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey,),
                  onPressed: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete this audio?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      await _deleteAudio(fileInfo['filePath']!);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
