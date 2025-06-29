import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mogapabahi/features/notification/view/notification_screen.dart';
import 'package:share_plus/share_plus.dart'; // Updated import
import 'package:mogapabahi/data/model/story.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';
import 'package:mogapabahi/widgets/music_widget.dart';
import 'package:cross_file/cross_file.dart'; // Required for XFile


class StoryDetailsPage extends StatelessWidget {
  final StoryModel? story;

  const StoryDetailsPage({super.key, this.story});

  Future<void> shareContent(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box!.localToGlobal(Offset.zero) & box.size;

    String text =
        "*${story!.title}*\n\n${story!.content}\n\nFor more story go to playstore and download\n\nLink: https://play.google.com/store/apps/details?id=com.krishnatechworld.mogapabahi";
    String imageUrl = story!.image.isNotEmpty
        ? story!.image
        : 'assets/images/home_banner_2.png';

    try {
      if (imageUrl.startsWith('http')) {
        // Download the image file to local storage
        final response = await http.get(Uri.parse(imageUrl));
        final documentDirectory = await getApplicationDocumentsDirectory();
        final file = File('${documentDirectory.path}/image.png');
        await file.writeAsBytes(response.bodyBytes);

        // Share the image file using SharePlus with proper parameters
        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)],
          text: text,
          sharePositionOrigin: sharePositionOrigin,
        ));
      } else {
        // If it's a local image, directly share it using SharePlus
        await SharePlus.instance.share(ShareParams(
          files: [XFile(imageUrl)],
          text: text,
          sharePositionOrigin: sharePositionOrigin,
        ));
      }
    } catch (e) {
      // Fallback to text sharing if file sharing fails
      await Share.share(
        text,
        subject: story!.title,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = story!.image.isNotEmpty
        ? story!.image
        : 'assets/images/home_banner_2.png';

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "ସମ୍ପୂର୍ଣ କାହାଣୀ",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 218, 142, 11),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  story!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (story!.image.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 3.0),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 5.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: imageUrl,
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Image.asset(
                  'assets/images/home_banner_2.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 26),
              const SizedBox(
                height: 120,
                child: MusicWidget(),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      story!.content,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 218, 142, 11),
          onPressed: () async {
            await shareContent(context);
          },
          child: const Icon(
            Icons.share,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
