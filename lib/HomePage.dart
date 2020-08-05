import 'package:flutter/material.dart';
import 'package:down/EnterPricePage.dart';
import 'package:down/FinanceTipsPage.dart';
import 'package:down/SettingsPage.dart';



class HomePage extends StatefulWidget {
  final String title = "NuBank Installment Visualizer";
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  // homepage variables
  PageController pageController;
  TabController tabController;
  int getPageIndex = 0;


  @override
  void initState() {
    super.initState();
    setState((){});
    tabController = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    //return RaisedButton.icon(onPressed: null, icon: Icon(Icons.close), label: Text("Sign Out"));
    return new Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        bottomNavigationBar: new Material(
            color: Theme.of(context).primaryColor,
            child: new TabBar(
                controller: tabController,
                tabs: <Tab>[
                  new Tab(child: new Icon(Icons.account_balance_wallet)),
                  new Tab(child: new Icon(Icons.lightbulb_outline)),
                  new Tab(child: new Icon(Icons.settings)),
                ]
            )
        ),
        body: new TabBarView(
            controller: tabController,
            children: <Widget>[
              new EnterPricePage(),
              new FinanceTipsPage(),
              new SettingsPage(),
              //new SearchPage()
            ]
        )
    );
  }

}