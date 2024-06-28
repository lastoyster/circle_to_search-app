import 'dart:io';

import 'package: circle_to_search_app/AlbumPage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GalleryHome(),
    );
  }
}

class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key});

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // loadAllAlbums();
    requestPermissions();
  }

  requestPermissions() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        loadAllAlbums();
      }
    } else if (Platform.isAndroid) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted &&
              await Permission.videos.request().isGranted) {
        loadAllAlbums();
      }
    }
  }

  List<Album> albums = [];
  loadAllAlbums() async {
    albums = await PhotoGallery.listAlbums(newest: true);
    albums.forEach((element) {
      print(element.name);
    });
    setState(() {
      albums;
    });
  }

  @override
  Widget build(BuildContext context) {
    double imageWidth = (MediaQuery.of(context).size.width - 15) / 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Gallery',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade400,centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 3,right: 3,top: 3),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 0.75),
          itemBuilder: (BuildContext ctx, int index) {
            Album album = albums[index];
            return InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return AlbumPage(album);
                }));
              },
              child: Container(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: imageWidth,
                        height: imageWidth,
                        child: FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image:
                              AlbumThumbnailProvider(album: album, highQuality: true),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      child: Text(
                        album.name.toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    Align(
                      child: Text(
                        album.count.toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                      alignment: Alignment.centerLeft,
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: albums.length,
        ),
      ),
    );
  }
}
