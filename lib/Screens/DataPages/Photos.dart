// ignore: file_names
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoPage extends StatefulWidget {
  final String id;
  const PhotoPage({super.key,required this.id});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {

  /* NOTE: KTranparentImage gives a fade image.
  Consider changing to set tile size beforehand?
  More work to be done here, but its beta for now */

  

  List<Card> getImages(String id){
    List<Card> imageList =[];

    imageList.add(Card(
      child: FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: NetworkImage('https://mesonet.climate.umt.edu/api/v2/photos/$id/n/?force=True')),
    )
      );

      imageList.add(Card(
        child: FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: NetworkImage('https://mesonet.climate.umt.edu/api/v2/photos/$id/e/?force=True')),
      )
      );

      imageList.add(Card(
        child: FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: NetworkImage('https://mesonet.climate.umt.edu/api/v2/photos/$id/s/?force=True')),
      )
      );

      imageList.add(Card(
        child: FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: NetworkImage('https://mesonet.climate.umt.edu/api/v2/photos/$id/w/?force=True')),
      )
      );

    return imageList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: getImages(widget.id),
          
        ),
    );
  }
}