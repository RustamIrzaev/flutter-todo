import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(ToDoApp());

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TODO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final _appColors = [
    Color.fromRGBO(255, 153, 102, 1.0),
    Color.fromRGBO(51, 153, 255, 1.0),
    Color.fromRGBO(0, 153, 0, 1.0)
  ];

  final _cardsList = [
    ToDoGroup("Private", 2, 0.66, Icons.account_circle),
    ToDoGroup("Work", 7, 0.33, Icons.work),
    ToDoGroup("Family", 2, 0.5, Icons.people),
  ];

  AnimationController _animationController;
  ColorTween _colorTween;
  CurvedAnimation _curvedAnimation;
  ScrollController _scrollController;
  int _cardIndex = 0;
  Color _currentColor;
  bool _hasReachedStart = true;
  bool _hasReachedEnd = false;

  _MyHomePageState() {
    _currentColor = _appColors[0];
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      drawer: Drawer(),
      backgroundColor: _currentColor,
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(
                      Icons.account_circle,
                      size: 42.0,
                      color: Colors.white
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 12.0),
                    child: Text(
                      "Good afternoon, Rustam",
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.white
                      ),
                    ),
                  ),
                  Text(
                    "Looks like feel good.",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  Text(
                    "You have 7 tasks to do today.",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 8.0),
                child: Text(
                  "TODAY: 11 Apr 2019",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                height: 300.0,
                child: ListView.builder(
//                  physics: NeverScrollableScrollPhysics(),
                  physics: ClampingScrollPhysics(),
                  itemCount: _cardsList.length,
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, position) {
                    return GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Hero(
                          tag: _cardsList[position],
                          child: Card(
                            child: Container(
                              width: 250.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(
                                          _cardsList[position].icon,
                                          color: _appColors[position],
                                          size: 32.0,
                                        ),
                                        Icon(Icons.more_vert, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          child: Text(
                                            "${_cardsList[position].tasksRemaining} Tasks",
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          child: Text(
                                            "${_cardsList[position].cardTitle} Tasks",
                                            style: TextStyle(fontSize: 28.0),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: LinearProgressIndicator(
                                            value: _cardsList[position].taskCompletion,
                                            backgroundColor: _appColors[position].withOpacity(0.3),
                                            valueColor: AlwaysStoppedAnimation<Color>(_appColors[position]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ToDoGroupsPage(_cardsList[position], _appColors[position])
                        ));
                      },
                      onHorizontalDragEnd: (details) {
                        _animationController = AnimationController(
                          vsync: this,
                          duration: Duration(milliseconds: 1000)
                        );

                        _curvedAnimation = CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.fastOutSlowIn
                        );

                        _animationController.addListener(() {
                          setState(() {
                            _currentColor = _colorTween.evaluate(_curvedAnimation);
                          });
                        });

                        var needToAnimate = false;

                        if (details.primaryVelocity > 0) {
                          if (!_hasReachedStart && _cardIndex > 0) {
                            _hasReachedEnd = false;
                            _cardIndex--;
                            needToAnimate = true;
                          } else {
                            _hasReachedStart = true;
                          }
                        } else if (details.primaryVelocity < 0) {
                          if (!_hasReachedEnd && _cardIndex < _cardsList.length - 1) {
                            _hasReachedStart = false;
                            _cardIndex++;
                            needToAnimate = true;
                          } else {
                            _hasReachedEnd = true;
                          }
                        }

                        if (needToAnimate) {
                          setState(() {
                            _scrollController.animateTo(
                                _cardIndex * 256.0,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeOutCirc
                            );
                          });

                          _colorTween = ColorTween(
                              begin: _currentColor,
                              end: _appColors[_cardIndex]
                          );
                          _colorTween.animate(_curvedAnimation);
                          _animationController.forward();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text("TODO",
        style: TextStyle(
          fontSize: 16.0
        ),
      ),
      backgroundColor: _currentColor,
      centerTitle: true,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(Icons.search),
        )
      ],
      elevation: 0.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class ToDoGroup {
  String cardTitle;
  int tasksRemaining;
  double taskCompletion;
  IconData icon;

  ToDoGroup(this.cardTitle, this.tasksRemaining, this.taskCompletion, this.icon);
}

class ToDoGroupsPage extends StatefulWidget {
  final ToDoGroup _group;
  final Color _color;

  ToDoGroupsPage(this._group, this._color);

  @override
  _ToDoGroupsPageState createState() => _ToDoGroupsPageState(_group, _color);
}

class _ToDoGroupsPageState extends State<ToDoGroupsPage> {
  final ToDoGroup _group;
  final Color _color;

  _ToDoGroupsPageState(this._group, this._color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _color,
      appBar: AppBar(
        title: Text("${_group.cardTitle} Tasks",
          style: TextStyle(
              fontSize: 16.0
          ),
        ),
        backgroundColor: _color,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Hero(
        tag: _group,
        transitionOnUserGestures: true,
        flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
          if (direction == HeroFlightDirection.push) {
            return Icon(
              Icons.open_in_new,
              size: 100.0,
              color: Colors.white
            );
          } else if (direction == HeroFlightDirection.pop) {
            return Icon(
              Icons.save_alt,
              size: 100.0,
              color: Colors.white,
            );
          }
        },
        child: Center(
          child: Text(
            "soon",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0
            ),
          ),
        )
      ),
    );
  }
}