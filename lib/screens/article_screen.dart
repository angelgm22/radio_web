import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'dart:js' as js;
import 'package:blur/blur.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

class ArticleScreen extends StatefulWidget {
  final String image, title, content, date, articleUrl, tipo;

  ArticleScreen(
      {required this.content,
      required this.date,
      required this.image,
      required this.title,
      required this.tipo,
      required this.articleUrl});

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  bool _showConnected = false;
  bool isLightTheme = true;
  int position = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.1),
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.1),
          elevation: 0.0,
          leading: IconButton(
            color: Colors.black12,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.cancel,
              size: 30,
              color: Colors.black,
            ),
          ),
          title: widget.tipo == 'anuncios'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Anuncio',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(width: 20),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Noticia',
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
          child:Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Hero(
                          tag: 'image-${widget.image}',
                          child: Image.network(
                            height: 330,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitHeight,
                            widget.image,

                          ),
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            widget.tipo == 'anuncios'
                                ? Text(
                                    'Anuncio',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        backgroundColor: Colors.amber),
                                  )
                                : SizedBox(),
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(widget.date,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12.0)),
                            SizedBox(
                              height: 6,
                            ),
                            Flexible(
                              child: Text(
                                widget.content,
                                //maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            widget.articleUrl.contains('http')
                                ? IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(widget.articleUrl));
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.facebook,
                                      size: 60,
                                      color: Colors.blue,
                                    )
                                                )
                                : SizedBox(),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ) //),
          )
          .frosted(
            blur: 12,
            frostColor: Colors.black,
            borderRadius: BorderRadius.circular(20),
            padding: EdgeInsets.all(8),
          ),
        ));
  }
}
