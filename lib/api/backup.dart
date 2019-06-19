import 'package:dio/dio.dart';
import 'dart:async';
import 'package:v2ex/const/constVar.dart';
import 'package:v2ex/model/model.dart';
import 'package:flutter/material.dart';

Dio dio = Dio();

Future fetchNodes(String group) async {
  NodeModel node = NodeModel();
  List allNodes = [];

  if (group == 'all') {
    RegExp nodeItemReg = RegExp('href="(.*?)" class="item_node">(.*?)</a>');
    Response html = await dio.get(nodeUrl);
    String contentHtml = html.data;

    var nodeMatches = nodeItemReg.allMatches(contentHtml).toList();
    nodeMatches.forEach((match) {
      node.nodeName = match.group(2);
      node.nodeUrl = match.group(1);
      allNodes.add(node);
      node = NodeModel();
    });
  } else if (group == 'hotnodes') {
    hotNodes.forEach((k, v) {
      node.nodeName = k;
      node.nodeUrl = v;
      allNodes.add(node);
      node = NodeModel();
    });
  }

  return allNodes;
}

Future fetchArticles(url) async {
  List<ArticleModel> articleList = [];
  ArticleModel article = ArticleModel();

  Response htmlObj = await dio.get(url);
  var content = htmlObj.data;
  content.forEach((jsonNode) {
    article.title = jsonNode['title'];
    article.url = jsonNode['url'];
    article.author = jsonNode['member']['username'];
    article.node = jsonNode['node']['name'];
    article.avatar = 'http:' + jsonNode['member']['avatar_normal'];

    articleList.add(article);
    article = ArticleModel();
  });

  return articleList;
}

Future fetchArticleContent(String url) async {
  ContentModel content = ContentModel();

//  String url = 'https://www.v2ex.com/t/551881';
  Response html = await dio.get(url);
  String contentHtml = html.data;

  RegExp replaceReg = RegExp('<((?!p|\/p|img|br|a|\/a).*?)>');

  RegExp titleReg = RegExp('<title>(.*?) - V2EX');
  RegExp mainPostOwnerReg = RegExp(
      '<small class="gray"><a href="(.*?)">(.*?)</a> · (.*?) · (.*?)</small>');
  RegExp mainPostReg = RegExp('<div class="topic_content">([^]+?)</div>');
  RegExp mainAvatarReg = RegExp(
      '<div class="header"><div class="fr"><a href="(.*)"><img src="(.*?)" class="avatar');

  RegExp replyReg = RegExp(
      '<table cellpadding="0" cellspacing="0" border="0" width="100%">([^]+?)</table>');
  RegExp replyContentReg = RegExp('<div class="reply_content">([^]+?)</div>');
  RegExp replyAvatarReg =
  RegExp('valign="top" align="center"><img src="(.*?)" class="avatar');
  RegExp replyMemberReg = RegExp(
      '<strong><a href="/member/(.*?)" class="dark">(.*?)</a></strong>(.*?)<span class="ago">(.*?)</span>');

  //title
  var titleMatch = titleReg.firstMatch(contentHtml);
  content.title = titleMatch.group(1);
  content.url = url;
  //main post elements
  var mainPostOwnerMatch = mainPostOwnerReg.firstMatch(contentHtml);
  content.owner = mainPostOwnerMatch.group(2);
  content.click = mainPostOwnerMatch.group(4);
  content.mainPostTime = mainPostOwnerMatch.group(3);
  //avatar
  var mainAvatarMatch = mainAvatarReg.firstMatch(contentHtml);
  content.ownerAvatar = 'http:' + mainAvatarMatch.group(2);
  //post content
  var mainPostMatches = mainPostReg.allMatches(contentHtml).toList();
  String mainPost = '';
  for (int i = 0; i < mainPostMatches.length; i++) {
    if (i == 0) {
      mainPost = mainPost + mainPostMatches[i].group(1);
    } else {
      mainPost = mainPost + '<br />补充附言:<br />' + mainPostMatches[i].group(1);
    }
  }
  //TODO mainPost convert to list Widget, include image;
  //replace all <> except a,img,@,br,p
  mainPost = mainPost.replaceAll(replaceReg, '');
  content.mainPost = convertToWidgetList(mainPost);

  //reply content
  var replyMatches = replyReg.allMatches(contentHtml).toList();
  content.replyPosts = {};
  if (replyMatches.length > 2) {
    for (int i = 1; i < replyMatches.length - 1; i++) {
      content.replyPosts[i] = {};

      var eachReplyHtml = replyMatches[i].group(0);
      //name, time
      var replyMemberAndTime = replyMemberReg.firstMatch(eachReplyHtml);
      content.replyPosts[i]['name'] = replyMemberAndTime.group(2);
      content.replyPosts[i]['time'] = replyMemberAndTime.group(4);
      //reply content
      var replyContentMatch = replyContentReg.firstMatch(eachReplyHtml);
      String replyContent = replyContentMatch.group(1);
      //avatar
      var replyAvatarMatch = replyAvatarReg.firstMatch(eachReplyHtml);
      content.replyPosts[i]['avatar'] = 'http:' + replyAvatarMatch.group(1);

      //replace all <> except a,@,p,br,img
      replyContent = replyContent.replaceAll(replaceReg, '');
      //convert to widgets
      content.replyPosts[i]['content'] = convertToWidgetList(replyContent);
    }
  }
  return content;
}

List convertToWidgetList(String content) {
  //1. use <br /> and <p></p> convert the string to list
  //2. for each child within the list, search image, @ and <a> and convert to Widget
  //3. convert other words to Widget.
  List<Widget> contentWidgets = [];
  RegExp pSliceReg = RegExp('<p>([^]+?)</p>');
  List slices = content.split('<br />');
  slices.forEach((slice) {
    List pSlices = pSliceReg.allMatches(slice).toList();
    if (pSlices.length == 0) {
      // slice is the String ,maybe include image, and @, and a
      contentWidgets.add(convertLinkToWidget(slice));
    } else {
      // several paragraph..
      pSlices.forEach((p) {
        String pSlice = p.group(1); //pSlice is the String, maybe include image, and @, and a;
        contentWidgets.add(convertLinkToWidget(pSlice));
      });
    }
  });
  return contentWidgets;
}

RichText convertLinkToWidget(String subString) {
  List<TextSpan> content = [];
  RegExp divide = RegExp(
      '@<a href="(.*?)">(.*?)</a>|<a target="_blank" href="(.*?)" rel="nofollow">(.*?)</a>|<img src="(.*?)"(.*?)">');
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
        //it's a href, use url_launcher, now use text first.
        String s2 = subString.substring(i, match.start);
        TextSpan s2Widget = TextSpan(text: s2, style: TextStyle(color: Colors.black));
        TextSpan url = TextSpan(text: match.group(4) + ':' + match.group(3), style: TextStyle(color: Colors.black));
        content.addAll([s2Widget, url]);
        i = match.end;
      } else if (match.group(5) != null) {
        //it's image, use Image
        String s3 = subString.substring(i, match.start);
        TextSpan s3Widget = TextSpan(text: s3, style: TextStyle(color: Colors.black));
//        var image = Image.network(match.group(5));   //change later to Image
        TextSpan image = TextSpan(text: match.group(5), style: TextStyle(color: Colors.black));
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
