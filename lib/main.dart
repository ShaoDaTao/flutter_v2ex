import 'package:flutter/material.dart';
import 'bloc/bloc.dart';
import 'package:v2ex/template/articleListPage.dart';
import 'const/constVar.dart';
import 'api/nodes_api.dart';
import 'bloc/bloc.dart';
import 'template/nodeListPage.dart';
import 'template/articlePage.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'model/model.dart';
import 'package:async/src/async_memoizer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RootWidget(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'V2EX app',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
          '/nodes': (context) => NodePage(),
          '/login': (context) => Login(),
          '/test': (context) => ArticlePage(ArticleBloc('https://www.v2ex.com/t/552543')),
        },
      ),
      bloc: UserBloc(),
    );
  }
}


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            indicatorColor: Colors.black38,
            indicatorWeight: 3.0,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                text: 'NEW',
              ),
              Tab(
                text: 'HOT',
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          ArticleList(ArticleListBloc(newArticleUrl)),
          ArticleList(ArticleListBloc(hotArticleUrl)),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
            onPressed: (){},
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            if(value == 0){
              Navigator.of(context).pushNamed('/nodes');
            }else{
              Navigator.of(context).pushNamed('/profile');
            }
          }, // TODO
          items: [
            BottomNavigationBarItem(
              title: Text('Home'),
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              title: Text('All nodes'),
              icon: Icon(Icons.grade),
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: InkWell(
                    child: Text('login'),
                    onTap: (){
                      Navigator.of(context).pushNamed('/login');
                    },
                  ),
                ),
                ListTile(
                  title: Text('收藏'),
                ),
                ListTile(
                  title: Text('我的资料'),
                ),
                ListTile(
                  title: Text('我的发贴'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState(LoginBloc());
  }
}

class LoginState extends State<Login> {
  LoginState(this.bloc);
  final LoginBloc bloc;

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController captchaController = TextEditingController();
  AsyncMemoizer asyncMemoizer = AsyncMemoizer();

  firstPost(loginModel) async{
    await postLogin(loginModel);
  }

  postLogin(LoginModel loginModel)async {
    Map data = {};
    if (nameController.text.isNotEmpty
        && passwordController.text.isNotEmpty
        && captchaController.text.isNotEmpty) {
          data = {
            loginModel.nameCode: nameController.text,
            loginModel.passwordCode: passwordController.text,
            loginModel.captchaCode: captchaController.text,
            'once': loginModel.once,
            'next': '/',
          };
          print(data);
          print(loginModel.session.headers);
          var response =await loginModel.session.post('https://www.v2ex.com/signin', data);
          print(response);
    }else{
      print('no data, cannot post');
    }
  }

  @override
  Widget build(BuildContext context) {
    asyncMemoizer.runOnce((){
      bloc.addLoginArgs();
    });
    return Scaffold(
      appBar: AppBar(title: Text('LOGIN'),),
      body: StreamBuilder(
        stream: bloc.dataBloc.stream,
          builder: (BuildContext context, snapshot){
            if(snapshot.hasData){
              LoginModel loginModel = snapshot.data;
              return Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        icon: Icon(Icons.supervised_user_circle),
                        labelText: 'name',
                      ),
                    ),),

                    Container(child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        icon: Icon(Icons.security),
                        labelText: 'password',
                      ),
                    ),),

                    Container(child: TextField(
                      controller: captchaController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        icon: Icon(Icons.image),
                        labelText: 'captcha',
                      ),
                    ),),

                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Image.network(loginModel.captchaUrl,
                        headers: loginModel.session.headers,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          RaisedButton(
                            child: Text('ok'),
//                              onPressed: firstPost(loginModel),
                            onPressed: (){
                              print('pressed');
                              firstPost(loginModel);
                              },
                          ),
                          SizedBox(width: 20.0,),
                          RaisedButton(child: Text('cancel'),onPressed: (){
                            Navigator.of(context).pop(context);
                          },),
                        ],
                      ),
                    ),
                  ],
                ),);
            }else{
              return Container(child: Text('getting data'),);
            }
          },
      ),
    );
  }
}


class RootWidget extends InheritedWidget {
  RootWidget({this.bloc, this.child}) : super(child: child);
  final UserBloc bloc;
  final Widget child;

  static RootWidget of(BuildContext context) =>
      (context).inheritFromWidgetOfExactType(RootWidget);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class NodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('V2EX Nodes'),
          bottom: TabBar(tabs: [
            Text('POPULAR NODES'),
            Text('ALL NODES'),
          ]),
        ),
        body: TabBarView(children: [
          NodeList(NodeListBloc('hotnodes')),
          NodeList(NodeListBloc('all')),
        ]),
      ),
    );
  }
}
