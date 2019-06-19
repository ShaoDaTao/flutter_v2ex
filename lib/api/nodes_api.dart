import 'package:dio/dio.dart';
import 'dart:async';
import 'package:v2ex/const/constVar.dart';
import 'package:v2ex/model/model.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:requests/requests.dart';
import 'package:http/http.dart' as http;
import 'package:simple_logger/simple_logger.dart';


Dio dio = Dio();

Future fetchLoginArgs (String loginUrl) async {
  print('getting here...................');
  String name, password, once, captcha;
  LoginModel loginModel = LoginModel();

  Session session = Session();

  String contentHtml = await session.get('https://www.v2ex.com/signin');
//  var response = await Requests.get('https://www.v2ex.com/signin');
//  Response response = await dio.get('https://www.v2ex.com/signin');
//  var contentHtml = response.data;
  RegExp nameReg = RegExp('input type="text" class="sl" name="(.*?)" value="" autofocus');
  RegExp passwordReg = RegExp('<input type="password" class="sl" name="(.*?)"');
  RegExp onceReg = RegExp('<input type="hidden" value="(.*?)" name="once"');
  RegExp captchaReg = RegExp('<input type="text" class="sl" name="(.*?)" value="" autocorrect');
  name = (nameReg.firstMatch(contentHtml)).group(1);
  password = (passwordReg.firstMatch(contentHtml)).group(1);
  captcha = (captchaReg.firstMatch(contentHtml)).group(1);
  once = (onceReg.firstMatch(contentHtml)).group(1);

  loginModel.nameCode = name;
  loginModel.passwordCode = password;
  loginModel.once = once;
  loginModel.session = session;
  loginModel.captchaCode = captcha;
  loginModel.captchaUrl = 'https://www.v2ex.com/_captcha?once=' + once;
  return loginModel;
}

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
    content.mainPost = mainPost;

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
      content.replyPosts[i]['content'] = replyContent;
    }
  }
  return content;
}


class Session {
  Map<String, String> headers = {
    'referer': 'https://www.v2ex.com/signin',
    'origin': 'https://www.v2ex.com',
  };

  Future<String> get(String url) async {
    http.Response response = await http.get(url, headers: headers);
    print('get start >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//    var logger = SimpleLogger();
//    logger.info(response);
//    print(response.body);
    debugPrint(response.body);
    print('get end >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    updateCookie(response);
    return response.body;
  }

  Future<String> post(String url, dynamic data) async {
    print('posted=>>>>>>>>>>');
    http.Response response = await http.post(url, body: data, headers: headers);
    updateCookie(response);
    print('from posting area=========start========');
    print(response.toString());
    print('from posting area=========devide========');
    print(response.body);

    print('from posting area========end=========');
    return response.body;
  }

  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}