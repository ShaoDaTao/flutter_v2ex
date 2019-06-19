import 'package:flutter/material.dart';
import 'package:v2ex/bloc/bloc.dart';
import 'package:v2ex/const/constVar.dart';
import 'package:v2ex/model/model.dart';
import 'package:v2ex/api/nodes_api.dart';
import 'articlePage.dart';


class ArticleList extends StatelessWidget {
  ArticleList(this._bloc);
  final ArticleListBloc _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc.addArticles();
    return StreamBuilder(
      stream: _bloc.dataBloc.stream,
      builder: (context, snapshot){
        if (snapshot.hasData) {
          List _articles = snapshot.data;
          return CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate((context, int index){
                  return Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 48.0,width: 48.0,
                          alignment: Alignment.center,
                          child: Image.network(_articles[index].avatar, fit: BoxFit.cover,),
                        ),
                      ),
                      Expanded(flex: 7,child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context){
                                  return ArticlePage(ArticleBloc(_articles[index].url));
                                })
                              );
                            },
                            child: Text(_articles[index].title),),
                          Text(_articles[index].author),
                          Divider(color: Colors.black26,),
                        ],
                      ),),
                    ],
                  );
                },
                  childCount: _articles.length,
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: LinearProgressIndicator(),
          );
        }
      },
    );
  }
}




//class ArticleList extends StatelessWidget {
//  ArticleList(this.bloc);
//  final ArticleListBloc bloc;
//
//  @override
//  Widget build(BuildContext context) {
//    bloc.addArticles();
//    return Column(
//      children: <Widget>[
//        Flexible(
//          child: StreamBuilder(
//            stream: bloc.dataBloc.stream,
//            builder: (BuildContext context, snapshot){
//              if (snapshot.hasData){
//                var _articles = snapshot.data;
//                return ListView.builder(
//                  itemBuilder: (BuildContext context1, int index){
//                    return ListTile(
//                      onTap: (){
//                        Navigator.of(context).push(
//                          MaterialPageRoute(builder: (context){
//                            return ArticlePage(ArticleBloc(_articles[index].url));
//                          })
//                        );
//                      },
//                      title: Text(_articles[index].title, maxLines: 2, overflow: TextOverflow.clip,),
//                      subtitle: Text(_articles[index].author),
//                    );
//                  },
//                  itemCount: _articles.length,
//                );
//              }else{
//                return Text('getting data');
//              }
//            },
//          ),
//        ),
//      ],
//    );
//  }
//}




//class ArticleList extends StatelessWidget {
//  ArticleList(this.bloc);
//  final ArticleListBloc bloc;
//
//  @override
//  Widget build(BuildContext context) {
//    bloc.addArticles();
//    return Column(
//      children: <Widget>[
//        Flexible(
//          child: StreamBuilder(
//            stream: bloc.dataBloc.stream,
//            builder: (BuildContext context, snapshot){
//              if (snapshot.hasData){
//                var _articles = snapshot.data;
//                return ListView.builder(
//                  itemBuilder: (BuildContext context1, int index){
//                    return ListTile(
//                      onTap: (){
//                        Navigator.of(context).push(
//                            MaterialPageRoute(builder: (context){
//                              return ArticlePage(ArticleBloc(_articles[index].url));
//                            })
//                        );
//                      },
//                      title: Text(_articles[index].title, maxLines: 2, overflow: TextOverflow.clip,),
//                      subtitle: Text(_articles[index].author),
//                    );
//                  },
//                  itemCount: _articles.length,
//                );
//              }else{
//                return Text('getting data');
//              }
//            },
//          ),
//        ),
//      ],
//    );
//  }
//}