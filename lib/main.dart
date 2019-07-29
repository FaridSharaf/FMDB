import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'FilmResponse.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:toast/toast.dart';
import 'MyHelper.dart';

const testGray = Color(0xFFECEFF1);
const testGray1 = Color(0xFFCFD8DC);
IconData favoriteIcon = Icons.favorite_border;

var helper = MyHelper();
var filmsCount;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
//      title: "FMdb",
//      color: Colors.amberAccent,
      home: HomeScreen(),
      routes: {
        FilmData.filmDataRoute: (context) => FilmData(),
        FavoriteScreen.favoriteRoute: (context) => FavoriteScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
//
//  var helper = MyHelper();
//  List<Film> films = List();

  int voteCount;
  var voteAverage;
  String title;
  double popularity;
  String posterPath;
  String originalLanguage;
  String backdropPath;
  String overview;
  String releaseDate;

  var results;

  Future<Response> fetchFilm() async {
    final response = await get(
        "https://api.themoviedb.org/3/movie/popular?api_key=d032214048c9ca94d788dcf68434f385");
    var jsonString = response.body;
    var parseJson = json.decode(jsonString);
    var filmResponse = Films.fromJson(parseJson);

    setState(() {
      results = filmResponse.results;
      filmsCount = filmResponse.results.length;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchFilm(); //call movies fetch function to get data from API
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (filmsCount == null) {
      return Scaffold(
        body: Center(
          child: Container(
            color: Colors.amber,
            child: Text(
              "FMdb",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        backgroundColor: Color(0xFFECEFF1),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Box Office",
            style: TextStyle(color: Colors.black),
          ),
          leading: Icon(
            (Icons.video_library),
            color: Colors.black,
          ),
          backgroundColor: Color.fromARGB(500, 255, 191, 0),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 10 / 15,
          children: List.generate(
            results.length,
            (index) {
              return Container(
                child: Card(
                  child: FlatButton(
                    onPressed: () {
                      Results film = Results();
                      film.id = results[index].id;
                      film.originalLanguage = results[index].originalLanguage;
                      film.posterPath = results[index].posterPath;
                      film.title = results[index].title;
                      film.backdropPath = results[index].backdropPath;
                      film.overview = results[index].overview;
                      film.voteAverage = results[index].voteAverage;
                      film.voteCount = results[index].voteCount;
                      film.popularity = results[index].popularity;
                      film.releaseDate = results[index].releaseDate;

                      Navigator.pushNamed(
                        context,
                        FilmData.filmDataRoute,
                        arguments: film,
                      );
                      print("Film: ${results[index].title}");
                    },
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "${results[index].title}",
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.ltr,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                            ),
                          ),
                          Image.network(
                            'http://image.tmdb.org/t/p/w500${results[index].posterPath}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        backgroundColor: Color(0xFFECEFF1),
      );
    }
  }

  void insertFilm(BuildContext context, Results film) {
    var f = Results.withInfo(
      film.id,
      film.title,
      film.overview,
      film.popularity,
      film.voteAverage,
      film.releaseDate,
      film.voteCount,
      film.posterPath,
      film.backdropPath,
    );
    helper.insertIntoTable(f);
    Toast.show("Saved!", context);
  }
}

class FilmData extends StatefulWidget {
  static final filmDataRoute = '/second';

  @override
  _FilmDataState createState() => _FilmDataState();
}

class _FilmDataState extends State<FilmData> {
  @override
  Widget build(BuildContext context) {
    Results film = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          film.title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(500, 255, 191, 0),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              favoriteIcon,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (favoriteIcon == Icons.favorite_border) {
                  insertFilm(context, film);
                  favoriteIcon = Icons.favorite;
                } else {
                  helper.deleteFilm(film.id);
                  favoriteIcon = Icons.favorite_border;
                  Toast.show("Removed!", context);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.movie,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                FavoriteScreen.favoriteRoute,
                arguments: film,
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
//              leading: Icon(Icons.title),
              title: Text(
                "${film.title}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
//              leading: Text("Title",style: ,),
            ),
            ListTile(
              title: Image.network(
                'http://image.tmdb.org/t/p/w500${film.backdropPath}',
              ),
            ),
            ListTile(
              title: Text("Overview"),
              subtitle: Text(film.overview,
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.black)),
              leading: Icon(
                Icons.title,
                size: 20.0,
              ),
            ),
            ListTile(
              title: Text(
                "Vote average: ${film.voteAverage}",
              ),
              leading: Icon(
                Icons.confirmation_number,
                size: 20.0,
              ),
            ),
            ListTile(
              title: Text("Popularity: ${film.popularity}"),
              trailing: Text("Votes:  ${film.voteCount}"),
              leading: Icon(
                Icons.thumbs_up_down,
                size: 20.0,
              ),
            ),
            ListTile(
              title: Text("Released: ${film.releaseDate}"),
              leading: Icon(
                Icons.date_range,
                size: 20.0,
              ),
            ),
          ],
        ).toList(),
      ),
      backgroundColor: Color(0xFFECEFF1),
    );
  }

  void insertFilm(BuildContext context, Results film) {
    var f = Results.withInfo(
      film.id,
      film.title,
      film.overview,
      film.popularity,
      film.voteAverage,
      film.releaseDate,
      film.voteCount,
      film.posterPath,
      film.backdropPath,
    );
    helper.insertIntoTable(f);
    Toast.show("Saved!", context);
  }
}

class FavoriteScreen extends StatefulWidget {
  static final favoriteRoute = '/third';

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Results> films = List();

  @override
  Widget build(BuildContext context) {
    Results films2 = ModalRoute.of(context).settings.arguments;
    select(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorites",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        centerTitle: false,
        backgroundColor: Color.fromARGB(500, 255, 191, 0),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Clear favorites?"),
                        content: Text("This will clear your favorite list."),
                        actions: <Widget>[
                          ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "CANCEL",
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ),
                              FlatButton(
                                onPressed: () {
                                  helper.deleteAll();
                                  Toast.show("Cleared!", context);
                                  favoriteIcon = Icons.favorite_border;
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "ACCEPT",
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    });
              });
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 10 / 15,
        children: List.generate(
          films.length,
          (index) {
            return Container(
              child: Card(
                child: FlatButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      FilmData.filmDataRoute,
                      arguments: films[index],
                    );
                    print("Film: ${films[index].title}");
                  },
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "${films[index].title}",
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                        ),
                        Image.network(
                          'http://image.tmdb.org/t/p/w500${films[index].posterPath}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Color(0xFFECEFF1),
    );
  }

//  Future select(BuildContext context) async {
//    var list = await helper.getFilms();
//    Toast.show(list.toString(), context);
//  }

  Future select(BuildContext context) async {
    helper.getFilms().then((filmsList) {
      setState(() {
        films = filmsList;
      });
    });
//    Toast.show(films.toString(), context);
  }
}
