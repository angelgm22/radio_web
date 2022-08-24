// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:radio_web/screens/article_screen.dart';
import 'package:radio_web/screens/image_screen.dart';
import 'package:transition/transition.dart';
import 'dart:js' as js;


class NewsTile extends StatelessWidget {
  final String image, title, content, date, fullArticle, tipo;
  NewsTile({
    required 
     this.content,
     required 
     this.date,
     required 
     this.image,
     required 
     this.title,
     required 
     this.fullArticle,
     required 
     this.tipo,
  });

  @override
  Widget build(BuildContext context) {


    print("URL image $image");
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(6))),
      margin: EdgeInsets.only(bottom: 24),
      width: MediaQuery.of(context).size.width ,
      // height: MediaQuery.of(context).size.height /2,

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Hero(
                  tag: 'image-$image',
                  child: Image.network(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                     image,
                    /*placeholder: (context, url) => Image(
                      image: AssetImage('images/dotted-placeholder.jpg'),
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ), */
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageScreen(
                      imageUrl: image,
                      headline: title,
                    ),
                  ),
                );
              },
            ),
            GestureDetector(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    tipo == 'anuncios'
                        ? Text(
                            'Anuncio',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                backgroundColor: Colors.amber),
                          )
                        : SizedBox(),
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      content,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(date,
                        style: TextStyle(color: Colors.grey, fontSize: 12.0))
                  ],
                ),
              ),
              onTap: () {
                tipo == 'news'  
                ?
                js.context.callMethod('open', [fullArticle])
                :

                Navigator.push(
                  context,
                  Transition(
                    child: ArticleScreen(
                      articleUrl: fullArticle,
                      content: content,
                      date: date,
                      image: image,
                      title: title,
                      tipo: tipo,
                    ),
                    transitionEffect: TransitionEffect.BOTTOM_TO_TOP,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
