import 'package:flutter/material.dart';
import 'package:v2ex/bloc/bloc.dart';

class NodeList extends StatelessWidget {
  NodeList(this._bloc);

  final NodeListBloc _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc.addNodes();
    return Column(
      children: <Widget>[
        Flexible(
          child: StreamBuilder(
            stream: _bloc.dataBloc.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var _nodes = snapshot.data;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 1.0,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: _nodes.length,
                  itemBuilder: (context, int index) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 5.0, offset: Offset(3.0, 3.0))],
                      ),
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: (){},
                        borderRadius: BorderRadius.circular(5.0),
                        child: Text(_nodes[index].nodeName),
                      ),
                    );
                  },
                );
              } else {
                return Text('getting data');
              }
            },
          ),
        ),
      ],
    );
  }
}
