import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/search_controller.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'SearchFoodCardWidget.dart';
import 'SearchRestaurantCardWidget.dart';

class SearchResultWidget extends StatefulWidget {
  String heroTag;

  SearchResultWidget({Key key, this.heroTag}) : super(key: key);

  @override
  _SearchResultWidgetState createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends StateMVC<SearchResultWidget> {
  SearchController _con;
  _SearchResultWidgetState() : super(SearchController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    color: Theme.of(context).hintColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    S.of(context).search,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  subtitle: Text(
                    S.of(context).ordered_by_nearby_first,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onChanged:  (text)  {
                    print('search:$text');
                    _con.searchText = text;
                    _con.listenForRestaurants();
                  },
                  onSubmitted: (text) {
                    //print('search:$text');
                    //_con.saveSearch(text);
                    //_con.listenForRestaurants(text);
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    hintText: S.of(context).search_for_restaurants_or_foods,
                    hintStyle: Theme.of(context)
                        .textTheme
                        .caption
                        .merge(TextStyle(fontSize: 14)),
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).accentColor),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                            Theme.of(context).focusColor.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                            Theme.of(context).focusColor.withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                            Theme.of(context).focusColor.withOpacity(0.1))),
                  ),
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _con.restaurants.isEmpty
                              ? Container(
                            height: 1,
                          )
                              : Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 20, right: 20),
                                child: ListTile(
                                  dense: true,
                                  contentPadding:
                                  EdgeInsets.symmetric(vertical: 0),
                                  title: Text(
                                    S.of(context).search_items,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                primary: false,
                                itemCount: _con.restaurants.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (_con.restaurants
                                          .elementAt(index)
                                          .type ==
                                          '1') {
                                        Navigator.of(context)
                                            .pushNamed('/Details',
                                            arguments: RouteArgument(
                                              id: _con.restaurants
                                                  .elementAt(index)
                                                  .id,
                                              heroTag: widget.heroTag,
                                            ));
                                      } else {
                                        Navigator.of(context).pushNamed('/Food',
                                            arguments: RouteArgument(
                                                id: _con.restaurants
                                                    .elementAt(index)
                                                    .id,
                                                heroTag: widget.heroTag));
                                      }
                                    },
                                    child: _con.restaurants
                                        .elementAt(index)
                                        .type ==
                                        '1'
                                        ? SearchRestaurantCardWidget(
                                        restaurant:
                                        _con.restaurants.elementAt(index),
                                        heroTag: widget.heroTag)
                                        : SearchFoodCardWidget(
                                        restaurant:
                                        _con.restaurants.elementAt(index),
                                        heroTag: widget.heroTag),
                                  );
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 20, right: 20),
                                child: ListTile(
                                  dense: true,
                                  contentPadding:
                                  EdgeInsets.symmetric(vertical: 0),
                                  title: Text(
                                    S.of(context).recents_search,
                                    style: Theme.of(context).textTheme.subhead,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                primary: false,
                                itemCount: _con.recent_search_restaurants.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/Details',
                                          arguments: RouteArgument(
                                            id: _con.recent_search_restaurants
                                                .elementAt(index)
                                                .id,
                                            heroTag: widget.heroTag,
                                          ));
                                    },
                                    child: SearchRestaurantCardWidget(
                                        restaurant: _con.recent_search_restaurants
                                            .elementAt(index),
                                        heroTag: widget.heroTag),
                                  );
                                },
                              )
                            ],
                          ),
                        ],
                      ))),
            ],
          ),
        ));
  }
}
