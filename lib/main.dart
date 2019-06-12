import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:convert';
import 'CustomIcons.dart';
import 'todo.dart';
import 'package:flutter/foundation.dart';
import 'CustomCheckboxTile.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foober',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'foober'),
    );
  }
}

class ColorChoice {
  const ColorChoice({@required this.primary, @required this.gradient});

  final Color primary;
  final List<Color> gradient;
}

class ColorChoices {
  static const List<ColorChoice> choices = [
    ColorChoice(primary: Color(0xFFF77B67), gradient: [const Color.fromRGBO(245, 68, 113, 1.0), const Color.fromRGBO(245, 161, 81, 1.0)]),
    ColorChoice(primary: Color(0xFF5A89E6), gradient: [const Color.fromRGBO(77, 85, 225, 1.0), const Color.fromRGBO(93, 167, 231, 1.0)]),
    ColorChoice(primary: Color(0xFF4EC5AC), gradient: [const Color.fromRGBO(61, 188, 156, 1.0), const Color.fromRGBO(61, 212, 132, 1.0)])
  ];
}

List<TodoObject> todos = [
  // TodoObject.import("SOME_RANDOM_UUID", "Custom", 1, ColorChoies.colors[0], Icons.alarm, [TaskObject("Task", DateTime.now()),TaskObject("Task2", DateTime.now()),TaskObject.import("Task3", DateTime.now(), true)]),
  TodoObject.import("SOME_RANDOM_UUID", "Driver", 1, ColorChoices.choices[0],Icons.person, {
    DateTime(2018, 5, 3): [
      TaskObject("Register", DateTime(2018, 5, 3)),
      TaskObject("Sign Up", DateTime(2018, 5, 3)),
    ],
  }),
  TodoObject("Restaurant",Icons.home),

  TodoObject("NGO",Icons.work),

];

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  ScrollController scrollController;
  Color backgroundColor;
  LinearGradient backgroundGradient;
  Tween<Color> colorTween;
  int currentPage = 0;
  Color constBackColor;

  @override
  void initState() {
    colorTween = ColorTween(begin: todos[0].color, end: todos[0].color);
    backgroundColor = todos[0].color;
    backgroundGradient = todos[0].gradient;
    scrollController = ScrollController();
    scrollController.addListener(() {
      ScrollPosition position = scrollController.position;
      ScrollDirection direction = position.userScrollDirection;
      int page = (position.pixels / (position.maxScrollExtent / (todos.length.toDouble() - 1))).toInt();
      double pageDo = (position.pixels / (position.maxScrollExtent / (todos.length.toDouble() - 1)));
      double percent = pageDo - page;
      if (todos.length - 1 < page + 1) {
        return;
      }
      colorTween.begin = todos[page].color;
      colorTween.end = todos[page + 1].color;
      setState(() {
        backgroundColor = colorTween.lerp(percent);
        backgroundGradient = todos[page].gradient.lerpTo(todos[page + 1].gradient, percent);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            //title: Text("Foober",style:TextStyle(fontFamily:'Script')),


            actions: <Widget>[


            ],
          ),
          body: Container(
            child: Stack(
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 50.0, right: 60.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [BoxShadow(color: Colors.black38, offset: Offset(5.0, 5.0), blurRadius: 15.0)],
                                  shape: BoxShape.circle,
                                ),

                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Foober",
                                style: TextStyle(color: Colors.white, fontSize: 50.0,fontFamily:'bahnschrift'),
                              ),
                            ),
                            Text(
                              "Help Children get the food they deserve",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Food is the ingredient that binds us together",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 350.0,
                        width: _width,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            TodoObject todoObject = todos[index];
                            EdgeInsets padding = const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 30.0);

                            double percentComplete = todoObject.percentComplete();

                            return Padding(
                                padding: padding,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(PageRouteBuilder(
                                        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => DetailPage(todoObject: todoObject),
                                        transitionsBuilder: (
                                          BuildContext context,
                                          Animation<double> animation,
                                          Animation<double> secondaryAnimation,
                                          Widget child,
                                        ) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0.0, 1.0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: Offset.zero,
                                                end: const Offset(0.0, 1.0),
                                              ).animate(secondaryAnimation),
                                              child: child,
                                            ),
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 1000)));
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), boxShadow: [BoxShadow(color: Colors.black.withAlpha(70), offset: const Offset(3.0, 10.0), blurRadius: 15.0)]),
                                      height: 250.0,
                                      child: Stack(
                                        children: <Widget>[
                                          Hero(
                                            tag: todoObject.uuid + "_background",
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Hero(
                                                        tag: todoObject.uuid + "_icon",
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            border: Border.all(color: Colors.grey.withAlpha(70), style: BorderStyle.solid, width: 1.0),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Icon(todoObject.icon, color: todoObject.color),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                            alignment: Alignment.topRight,
                                                            child: Hero(
                                                              tag: todoObject.uuid + "_more_vert",
                                                              child: Material(
                                                                color: Colors.transparent,
                                                                type: MaterialType.transparency,
                                                                child: PopupMenuButton(
                                                                  icon: Icon(
                                                                    Icons.more_vert,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  itemBuilder: (context) => <PopupMenuEntry<TodoCardSettings>>[

                                                                      ],
                                                                  onSelected: (setting) {
                                                                    switch (setting) {
                                                                      case TodoCardSettings.edit_color:
                                                                        print("edit color clicked");
                                                                        break;
                                                                      case TodoCardSettings.delete:
                                                                        print("delete clicked");
                                                                        setState(() {
                                                                          todos.remove(todoObject);
                                                                        });
                                                                        break;
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            )),
                                                      )
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 20.0),
                                                  child: Align(
                                                      alignment: Alignment.bottomLeft,
                                                      child: Hero(
                                                        tag: todoObject.uuid + "_title",
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: Text(
                                                            todoObject.title,
                                                            style: TextStyle(fontSize: 30.0),
                                                            softWrap: false,
                                                          ),
                                                        ),
                                                      )),
                                                ),

                                            ]),
                                          ),
                                        ],
                                      )),
                                ));
                          },
                          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                          scrollDirection: Axis.horizontal,
                          physics: CustomScrollPhysics(),
                          controller: scrollController,
                          itemExtent: _width - 80,
                          itemCount: todos.length,
                        ),
                      )
                    ],
                  ),
                ),

              ],
            ),
          )),
    );
  }
}



enum TodoCardSettings { edit_color, delete }

class DetailPage extends StatefulWidget {
  DetailPage({@required this.todoObject, Key key}) : super(key: key);

  final TodoObject todoObject;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {

  final myController = TextEditingController();
  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();
  final myController4 = TextEditingController();
  final myController5 = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.reference();

    Map getData(){
    databaseReference.child('foober-4728a').child('Users').once().then((DataSnapshot snapshot){
      var data = snapshot.value;
    });
  }

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void dispose1(){
    myController1.dispose();
    super.dispose();
  }

  @override
  void dispose2(){
    myController2.dispose();
    super.dispose();
  }

  @override
  void dispose3(){
    myController3.dispose();
    super.dispose();
  }

  @override
  void dispose4(){
    myController4.dispose();
    super.dispose();
  }

  @override
  void dispose5(){
    myController5.dispose();
    super.dispose();
  }

  void _onclick() {
    setState(() {
      TextField(
        keyboardType:TextInputType.emailAddress,
        obscureText: true,

        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(
                20.0, 15.0, 20.0, 15.0),
            hintText: "Username",
            border:
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))),
      );
      TextField(
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(
                20.0, 15.0, 20.0, 15.0),
            hintText: "Password",
            border:
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))),
      );
      TextField(
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(
                20.0, 15.0, 20.0, 15.0),
            hintText: "phone number",
            border:
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))),
      );

      TextField(
        obscureText: true,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(
                20.0, 15.0, 20.0, 15.0),
            hintText: "Name Of Organisation",
            border:
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0))),
      );
    });
  }
  double percentComplete;
  AnimationController animationBar;
  double barPercent = 0.0;
  Tween<double> animT;
  AnimationController scaleAnimation;



  @override
  void initState() {
    scaleAnimation = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1000),
        lowerBound: 0.0,
        upperBound: 1.0);

    percentComplete = widget.todoObject.percentComplete();
    barPercent = percentComplete;
    animationBar = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
      ..addListener(() {
        setState(() {
          barPercent = animT.lerp(animationBar.value);
        });
      });
    animT = Tween<double>(begin: percentComplete, end: percentComplete);
    scaleAnimation.forward();
    super.initState();
  }

  void updateBarPercent() async {
    double newPercentComplete = widget.todoObject.percentComplete();
    if (animationBar.status == AnimationStatus.forward ||
        animationBar.status == AnimationStatus.completed) {
      animT.begin = newPercentComplete;
      await animationBar.reverse();
    } else {
      animT.end = newPercentComplete;
      await animationBar.forward();
    }
    percentComplete = newPercentComplete;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Hero(
            tag: widget.todoObject.uuid + "_background",
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: <Widget>[
                ],
              ),
              body: Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, right: 40.0, top: 35.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Hero(
                              tag: widget.todoObject.uuid + "_icon",
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey.withAlpha(70),
                                      style: BorderStyle.solid,
                                      width: 1.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    widget.todoObject.icon,
                                    color: widget.todoObject.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Hero(
                              tag: widget.todoObject.uuid + "_title",
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  widget.todoObject.title,
                                  style: TextStyle(fontSize: 50.0),
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ),
                        ),


                        TextField(
                          obscureText: false,
                           controller: myController,
                           decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                  20.0, 15.0, 20.0, 15.0),
                              hintText: "Email",
                              border:
                              OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0))),
                        ),

                        Text(
                            '                                                                   '
                        ),


                        TextField(
                          obscureText: true,
                          controller: myController1,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(
                                  20.0, 15.0, 20.0, 15.0),
                              hintText: "Password",
                              border:
                              OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0))),
                        ),


                        Text(
                            '                                                                   '
                        ),

                        Text(
                            '                                                                   '
                        ),

                        Text(
                            '                                                                   '
                        ),

                        Text(
                            '                                                                   '
                        ),
                        
                        Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(30.0),
                            color: Color(0xffD53700),
                            child: MaterialButton(
                                minWidth: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                padding: EdgeInsets.fromLTRB(
                                    20.0, 15.0, 20.0, 15.0),
                                onPressed: (){
                                  var val1 = {'Username':Text(myController.text),'Password':Text(myController1.text)};
                                  var vals  = getData();

                                  },
                                child: Text("Login",
                                  textAlign: TextAlign.center,

                                ))),
              Text(
                '                                                                   '
              ),
                        Text(
                            '                                                                   '
                        ),
                        Text(
                            '                                                                   '
                        ),
                        Text(
                            '                                                                   '
                        ),
                        Text(
                            '                                                                   '
                        ),
                        Text(
                            '                                                                   '
                        ),
                        Text(
                            '                                                                   '
                        ),
                        Text(
                            '                                                                   '
                        ),

                        Text(
                            'If you dont have an account please sign up',
                                style: (
                                    TextStyle(fontFamily:'Helvetica',fontSize:20.0)

                                ),
                          textAlign: TextAlign.center,

                        ),
                        Text(
                            '                                                                   '
                        ),
              Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30.0),
              color: Color(0xffD53700),
              child: MaterialButton(
                  minWidth: MediaQuery
                      .of(context)
                      .size
                      .width,
                  padding: EdgeInsets.fromLTRB(
                      20.0, 15.0, 20.0, 15.0),


                  child: Text("Register",
                    textAlign: TextAlign.center),


                    onPressed: () {
    return showDialog(
    context: context,

    barrierDismissible: false,
        builder:(BuildContext context){
    return AlertDialog(
      title:Text("Enter email,password,phone number, organisation"),
      content:new Row(
        children: <Widget>[
          new Expanded(
          child:new TextField(
            keyboardType:TextInputType.emailAddress,
            obscureText: true,
            controller: myController2,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                    20.0, 15.0, 20.0, 15.0),
                hintText: "Username",
                border:
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0))),
          ),

          ),
          new Expanded(
          child: new TextField(
            keyboardType:TextInputType.emailAddress,
            obscureText: true,
            controller: myController3,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                    20.0, 15.0, 20.0, 15.0),
                hintText: "Password",
                border:
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0))),
          )),
          new Expanded(
          child: new TextField(
            keyboardType:TextInputType.emailAddress,
            obscureText: true,
            controller: myController4,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                    20.0, 15.0, 20.0, 15.0),
                hintText: "Phone Number",
                border:
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0))),
          )),
          new Expanded(
          child: new TextField(
            keyboardType:TextInputType.emailAddress,
            obscureText: true,
            controller: myController5,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(
                    20.0, 15.0, 20.0, 15.0),
                hintText: "Organisation",
                border:
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0))),
          ))
        ],
      ),

      actions: <Widget>[
        FlatButton(
          child: Text("Complete Registration"),
          onPressed: () {
            final val1 = [Text(myController2.text),Text(myController3.text),Text(myController4.text),Text(myController5.text)];
          },
        )
      ],








    );




    });}


                ))
                      ])))
        ]);
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  CustomScrollPhysics({
    ScrollPhysics parent,
  }) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels / (position.maxScrollExtent / (todos.length.toDouble() - 1));
    // return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    // return page * position.viewportDimension;
    return page * (position.maxScrollExtent / (todos.length.toDouble() - 1));
  }

  double _getTargetPixels(ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) || (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
    return null;
  }
}
