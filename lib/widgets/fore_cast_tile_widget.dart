import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForeCastTileWidget extends StatelessWidget {
  String? temp;
  String? imageUrl;
  String? time;

  ForeCastTileWidget({super.key,required this.temp,required this.time,required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(temp ?? '', style: TextStyle(color: Colors.white),),
            CachedNetworkImage(imageUrl: imageUrl ?? '',
              height: 50,
              width: 50,
              fit: BoxFit.fill,
              progressIndicatorBuilder: (context,url,downloadProgress) => CircularProgressIndicator(),
              errorWidget: (context,url,err) => Icon(Icons.image,color: Colors.white,),),
            Text(time ?? '', style: TextStyle(color: Colors.white),),
          ],
        ),
      ),
    );
  }
}
