import 'package:rxdart/rxdart.dart';
import 'package:v2ex/const/constVar.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:v2ex/model/model.dart';
import 'package:v2ex/api/nodes_api.dart';

Dio dio = Dio();

abstract class BlocBase {
  PublishSubject dataBloc = PublishSubject();

  BlocBase() {
    dataBloc.listen(onData);
  }

  void onData(value) {
  }

  void dispose(){
    dataBloc.close();
  }
}

class LoginBloc extends BlocBase {
  void addLoginArgs()async{
    var data = await fetchLoginArgs(loginUrl);
    dataBloc.add(data);
  }
}

class UserBloc extends BlocBase {}

//class HomeBloc extends BlocBase {}

class ArticleListBloc extends BlocBase {
  ArticleListBloc(this.url);
  String url;

  void addArticles() async {
    var data = await fetchArticles(url);
    dataBloc.add(data);
    data = [];
  }
}

class NodeListBloc extends BlocBase {
  NodeListBloc(this.group);
  String group;

  void addNodes() async {
    var data = await fetchNodes(group);
    dataBloc.add(data);
  }
}

class ArticleBloc extends BlocBase{
  ArticleBloc(this.url);
  String url;
  void addContent() async{
    var data = await fetchArticleContent(url);
    dataBloc.add(data);
  }
}

class PublicFuncBloc extends BlocBase {}