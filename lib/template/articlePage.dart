import 'package:flutter/material.dart';
import 'package:v2ex/bloc/bloc.dart';
import 'package:v2ex/model/model.dart';
import 'package:v2ex/template/toweb.dart';
import 'package:flutter/gestures.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage(this.bloc);
  final ArticleBloc bloc;

  @override
  State<StatefulWidget> createState() {
    return ArticlePageState(bloc);
  }
}

class ArticlePageState extends State<ArticlePage> {
  ArticlePageState(this.bloc);
  final ArticleBloc bloc;
  String _title;

  _showReplyField(){
    showDialog(
        context: context,
      builder: (BuildContext context){
          return SimpleDialog(
            title: Text('reply: $_title', style: TextStyle(fontSize: 12),),
            children: <Widget>[
              TextField(maxLines: 25,),
              Row(
                children: <Widget>[
                  FlatButton(child: Text('reply'),),
                  FlatButton(child: Text('cancel'),),
                ],
              ),
            ],
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bloc.addContent();
    return StreamBuilder(
      stream: bloc.dataBloc.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ContentModel content = snapshot.data;
          _title = content.title;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                content.title,
                style: TextStyle(fontSize: 14.0),
              ),
            ),
            body: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, int index) {
                      Container postPiece;
                      if (index == 0) {
                        //main post
                        postPiece = Container(
                            padding: EdgeInsets.all(2.0),
                            child:Flex(
                          direction: Axis.vertical,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 50.0,
                              color: Colors.black38,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Image.network(
                                      content.ownerAvatar,
                                      fit: BoxFit.cover,
                                    ),
                                    padding: EdgeInsets.all(7.0),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      content.owner,
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(content.mainPostTime + '  ' + content.click),
                                    ),
                                  ),
//                                  Container(
//                                    width:50.0,
//                                    child: PublicFunc(),
//                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: convertToWidgetList(content.mainPost, context),
                              ),
                            ),
                            Container(
                                    width:50.0,
                                    child: PublicFunc(),
                                  ),
                            Divider(color: Colors.black38,),
                          ],
                        )
                        );
                      } else if (content.replyPosts.length > 0) {
                        //replies
                        if (content.replyPosts.length > index) {
                          postPiece = Container(
                            padding: EdgeInsets.all(2.0),
                              child:Flex(
                            direction: Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                height: 50.0,
                                color: Colors.black38,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(7.0),
                                      child: Image.network(
                                          content.replyPosts[index]
                                              ['avatar']), //avatar
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: Text(content.replyPosts[index]
                                          ['name']), //name
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            content.replyPosts[index]['time']),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                alignment: Alignment.topLeft,
                                child: convertToWidgetList(content.replyPosts[index]['content'], context)[0],
                              ),
                            ],
                          ));
                        } else if (content.replyPosts.length == index) {
                          postPiece = Container(
                              padding: EdgeInsets.all(2.0),
                              child:Flex(
                            direction: Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                height: 50.0,
                                color: Colors.black38,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      child: Image.network(
                                          content.replyPosts[index]
                                              ['avatar']), //avatar
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: Text(content.replyPosts[index]
                                          ['name']), //name
                                    ),
                                    Expanded(child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          content.replyPosts[index]['time']),
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                alignment: Alignment.topLeft,
                                child: convertToWidgetList(content.replyPosts[index]['content'], context)[0],
                              ),
                              Container(
                                child: Text('1,2,3,4,5 pages'),
                              ),
                            ],
                          ));
                        }
                      }
                      return postPiece;
                    },
                    childCount: content.replyPosts.length + 1,
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            floatingActionButton: FloatingActionButton(
//                onPressed: _showReplyField(content.title),
                onPressed: _showReplyField,
//                onPressed: (){print('pressed..........');},
              child: Text('REPLY'),
            ),

          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('pending... ...'),
            ),
            body: Center(
              child: LinearProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class PublicFunc extends StatelessWidget {
  final PublicFuncBloc bloc = PublicFuncBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.dataBloc.stream,
      builder: (context, snapshot) {
        var funcWidget;
        if (snapshot.hasData) {
          var data = snapshot.data;
          if (data == 'unfavorite') {
            funcWidget = InkWell(
                child: Icon(Icons.favorite_border),
                onTap: () {
                  bloc.dataBloc.add('favorite');
                });
          } else if (data == 'favorite') {
            funcWidget = InkWell(
                child: Icon(Icons.favorite),
                onTap: () {
                  bloc.dataBloc.add('unfavorite');
                });
          }
        } else {
          funcWidget = InkWell(
              child: Icon(Icons.favorite_border),
              onTap: () {
                bloc.dataBloc.add('favorite');
              });
        }
        return funcWidget;
      },
    );
  }
}


List convertToWidgetList(String content, context) {
  //1. use <br /> and <p></p> convert the string to list
  //2. for each child within the list, search image, @ and <a> and convert to Widget
  //3. convert other words to Widget.
  List<Widget> contentWidgets = [];
  RegExp pSliceReg = RegExp('<p>([^]+?)</p>');
  List slices = content.split('<br />');
  slices.forEach((slice) {
    List pSlices = pSliceReg.allMatches(slice).toList();
    if (pSlices.length == 0) {
      // slice is the String, include image, and @, and a
      contentWidgets.add(convertLinkToWidget(slice, context));
    } else {
      // several paragraph..
      pSlices.forEach((p) {
        String pSlice = p.group(1); //pSlice is the String, include image, and @, and a;
        contentWidgets.add(convertLinkToWidget(pSlice, context));
      });
    }
  });
  return contentWidgets;
}

RichText convertLinkToWidget(String subString, context) {
  List<TextSpan> content = [];
  RegExp divide = RegExp(
      '@<a href="(.*?)">(.*?)</a>|<a[.]+?href="(.*?)" rel="nofollow">(.*?)</a>|<img src="(.*?)"(.*?)">');
  List pieces = divide.allMatches(subString).toList();
  int i = 0;
  if (pieces.length != 0) {
    pieces.forEach((match) {
      if (match.group(1) != null) {
        //TODO it's @function, replace with @ page later,
        String s1 = subString.substring(i, match.start);
        TextSpan s1Widget = TextSpan(text: s1, style: TextStyle(color: Colors.black));
        TextSpan name = TextSpan(text: match.group(2), style: TextStyle(color: Colors.black));
        content.addAll([s1Widget, name]);
        i = match.end;
      } else if (match.group(3) != null) {
        //it's a href, use webview to launch it
        String s2 = subString.substring(i, match.start);
        TextSpan s2Widget = TextSpan(text: s2, style: TextStyle(color: Colors.black));
        TextSpan url = TextSpan(text: match.group(4) + ':' + match.group(3), style: TextStyle(color: Colors.black));
        content.addAll([s2Widget, url]);
        i = match.end;
      } else if (match.group(5) != null) {
        //it's image, use Image
        String s3 = subString.substring(i, match.start);
        TextSpan s3Widget = TextSpan(text: s3, style: TextStyle(color: Colors.black));
        TextSpan image = TextSpan(
            text: match.group(5),
            style: TextStyle(color: Colors.black),
          recognizer: TapGestureRecognizer()..onTap=()=>Navigator.of(context).push(
              MaterialPageRoute(builder: (_){
                return ToImage(url:match.group(5));
              })
          ),
        );
        content.addAll([s3Widget, image]);
        i = match.end;
      }
      String s4 = subString.substring(i, subString.length);
      TextSpan endWidget = TextSpan(text: s4, style: TextStyle(color: Colors.black));
      content.add(endWidget);
    });
  } else {
    TextSpan s0 = TextSpan(text: subString, style: TextStyle(color: Colors.black));
    content.add(s0);
  }
  var paragraph = RichText(
    text: TextSpan(
      style: TextStyle(color: Colors.black),
      children: content,
    ),
  );

  return paragraph;
}


//class ArticlePage extends StatelessWidget {
//  ArticlePage(this.bloc);
//
//  final ArticleBloc bloc;
//
//  _showDialog(){
//    print('dialog pressed');
//    showDialog(
//        context: context,
//      builder: (BuildContext context){
//          return SimpleDialog(
//            title: Text('just test'),
//          );
//      },
//    );
//    print('the end dialog');
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    bloc.addContent();
//    return StreamBuilder(
//      stream: bloc.dataBloc.stream,
//      builder: (context, snapshot) {
//        if (snapshot.hasData) {
//          ContentModel content = snapshot.data;
//          return Scaffold(
//            appBar: AppBar(
//              title: Text(
//                content.title,
//                style: TextStyle(fontSize: 14.0),
//              ),
//            ),
//            body: CustomScrollView(
//              slivers: [
//                SliverList(
//                  delegate: SliverChildBuilderDelegate(
//                        (context, int index) {
//                      Flex postPiece;
//                      if (index == 0) {
//                        //main post
//                        postPiece = Flex(
//                          direction: Axis.vertical,
//                          mainAxisSize: MainAxisSize.min,
//                          children: <Widget>[
//                            Container(
//                              child: Row(
//                                mainAxisAlignment: MainAxisAlignment.start,
//                                children: <Widget>[
//                                  Container(
//                                    child: Image.network(
//                                      content.ownerAvatar,
//                                      fit: BoxFit.cover,
//                                    ),
//                                    decoration: BoxDecoration(
//                                        color: Colors.grey,
//                                        boxShadow: [
//                                          BoxShadow(
//                                              color: Colors.black54,
//                                              offset: Offset(2.0, 0.0),
//                                              blurRadius: 4.0),
//                                        ]),
//                                    width: 45.0,
//                                    height: 45.0,
//                                    padding: EdgeInsets.all(7.0),
//                                  ),
//                                  Container(
//                                    width: 100.0,
//                                    height: 45.0,
//                                    child: Text(
//                                      content.owner,
//                                    ),
//                                    decoration: BoxDecoration(
//                                        color: Colors.red,
//                                        boxShadow: [
//                                          BoxShadow(
//                                              color: Colors.black54,
//                                              offset: Offset(2.0, 2.0),
//                                              blurRadius: 4.0),
//                                        ]),
//                                    padding: EdgeInsets.all(10.0),
//                                    alignment: Alignment.center,
//                                  ),
//                                  Expanded(
//                                    child: Container(
////                                    width: double.infinity,
//                                      height: 45.0,
//                                      child: Text(content.mainPostTime),
//                                      decoration: BoxDecoration(
//                                          color: Colors.grey,
//                                          boxShadow: [
//                                            BoxShadow(
//                                                color: Colors.black54,
//                                                offset: Offset(2.0, 2.0),
//                                                blurRadius: 4.0),
//                                          ]),
//                                    ),
//                                  ),
//                                  Container(
////                                    width: double.infinity,
//                                    height: 45.0,
//                                    child: Text(content.click),
//                                    decoration: BoxDecoration(
//                                        color: Colors.grey,
//                                        boxShadow: [
//                                          BoxShadow(
//                                              color: Colors.black54,
//                                              offset: Offset(2.0, 2.0),
//                                              blurRadius: 4.0),
//                                        ]),
//                                  ),
//                                ],
//                              ),
//                            ),
//                            Flexible(
//                              child: Column(
//                                children: content.mainPost,
//                              ),
//                            ),
//                            Container(
//                              child: PublicFunc(),
//                            )
//                          ],
//                        );
//                      } else if (content.replyPosts.length > 0) {
//                        //replies
//                        if (content.replyPosts.length > index) {
//                          postPiece = Flex(
//                            direction: Axis.vertical,
//                            mainAxisSize: MainAxisSize.min,
//                            children: <Widget>[
//                              Container(
//                                child: Row(
//                                  children: <Widget>[
//                                    Container(
//                                      child: Image.network(
//                                          content.replyPosts[index]
//                                          ['avatar']), //avatar
//                                    ),
//                                    Container(
//                                      child: Text(content.replyPosts[index]
//                                      ['name']), //name
//                                    ),
//                                    Container(
//                                      child: Text(
//                                          content.replyPosts[index]['time']),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                              Container(
//                                child: content.replyPosts[index]['content'][0],
//                              ),
//                            ],
//                          );
//                        } else if (content.replyPosts.length == index) {
//                          postPiece = Flex(
//                            direction: Axis.vertical,
//                            mainAxisSize: MainAxisSize.min,
//                            children: <Widget>[
//                              Container(
//                                child: Row(
//                                  children: <Widget>[
//                                    Container(
//                                      child: Image.network(
//                                          content.replyPosts[index]
//                                          ['avatar']), //avatar
//                                    ),
//                                    Container(
//                                      child: Text(content.replyPosts[index]
//                                      ['name']), //name
//                                    ),
//                                    Container(
//                                      child: Text(
//                                          content.replyPosts[index]['time']),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                              Container(
//                                child: content.replyPosts[index]['content'][0],
//                              ),
//                              Container(
//                                child: Text('1,2,3,4,5 pages'),
//                              ),
//                            ],
//                          );
//                        }
//                      }
//                      return postPiece;
//                    },
//                    childCount: content.replyPosts.length + 1,
//                  ),
//                ),
//              ],
//            ),
//            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//            floatingActionButton: FloatingActionButton(
//              onPressed: _showDialog,
//              child: Icon(Icons.add),
//            ),
//            bottomNavigationBar: BottomNavigationBar(items: [
//              BottomNavigationBarItem(
//                  icon: Icon(Icons.home), title: Text('home')),
//              BottomNavigationBarItem(icon: Icon(Icons.map), title: Text('My')),
//            ]),
//          );
//        } else {
//          return Scaffold(
//            appBar: AppBar(
//              title: Text('pending... ...'),
//            ),
//            body: Text('has no data'),
//          );
//        }
//      },
//    );
//  }
//}