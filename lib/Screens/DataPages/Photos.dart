// ignore: file_names
import 'package:flutter/material.dart';

class PhotoPage extends StatefulWidget {
  final String id;
  const PhotoPage({super.key, required this.id});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  /* NOTE: KTranparentImage gives a fade image.
  Consider changing to set tile size beforehand?
  More work to be done here, but its beta for now */

  List<Widget> getImages(String id) {
    List<Widget> imageList = [];

    imageList.add(Image.network(
        'https://mesonet.climate.umt.edu/api/v2/photos/$id/n/?force=True',
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),));

    imageList.add(Image.network(
        'https://mesonet.climate.umt.edu/api/v2/photos/$id/w/?force=True',
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
      return Image.network(
          'https://mesonet.climate.umt.edu/api/v2/photos/$id/ns/?force=True',
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),);
    }));

    imageList.add(Image.network(
        'https://mesonet.climate.umt.edu/api/v2/photos/$id/s/?force=True',
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),));

    imageList.add(Image.network(
        'https://mesonet.climate.umt.edu/api/v2/photos/$id/e/?force=True',
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
      return Image.network(
          'https://mesonet.climate.umt.edu/api/v2/photos/$id/ss/?force=True',
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),);
    }));

    return imageList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

      ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: PageScrollPhysics(),

        itemBuilder: (context, index) {
        return getImages(widget.id)[index % 4];
      })
      ],
    );
  }
}
