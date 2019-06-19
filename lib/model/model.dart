import 'dart:async';
import 'package:v2ex/const/constVar.dart';
import 'package:flutter/material.dart';
import 'package:v2ex/api/nodes_api.dart';

class LoginModel {
  String nameCode;
  String passwordCode;
  String captchaCode;
  String captchaUrl;
  String once;
  Session session;

  LoginModel({
    this.nameCode,
    this.passwordCode,
    this.captchaCode,
    this.captchaUrl,
    this.once,
    this.session,
});
}

class NodeModel {
  String nodeName;
  String nodeUrl;

  NodeModel({
    this.nodeName,
    this.nodeUrl
  });
}

class ArticleModel {
  String title;
  String url;
  String author;
  String node;
  String avatar;

  ArticleModel({
    this.title,
    this.url,
    this.author,
    this.node,
    this.avatar
  });
}

class ContentModel {
  String title;
  String url;
  String owner;
  String ownerAvatar;
  String mainPost;
  String mainPostTime;
  List imgUrl;
  String click;

  Map replyPosts;
  // {1:{  reply: name,time,content,avatar}, 2:{}}

  ContentModel({
    this.title,
    this.url,
    this.owner,
    this.ownerAvatar,
    this.mainPost,
    this.mainPostTime,
    this.imgUrl,

    this.replyPosts,
  });
}