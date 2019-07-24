import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'FilmResponse.dart';
import 'package:carousel_slider/carousel_slider.dart';

const testGray = Color(0xFFECEFF1);
const testGray1 = Color(0xFFCFD8DC);

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
      routes: {FilmData.filmDataRoute: (context) => FilmData()},
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
//  List<Results> filmsList = List();

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
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fetchFilm(); //call movies fetch function to get data from API

    if (results.length == null) {
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
                      Film film = Film();
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
}

class FilmData extends StatefulWidget {
  static final filmDataRoute = '/second';

  @override
  _FilmDataState createState() => _FilmDataState();
}

class _FilmDataState extends State<FilmData> {
  @override
  Widget build(BuildContext context) {
    Film film = ModalRoute.of(context).settings.arguments;

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
                Icons.favorite_border,
                color: Colors.black,
              ),
              onPressed: () {}),
          IconButton(
            icon: Icon(
              Icons.movie,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              Navigator.pop(context);
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
            ),
            ListTile(
              leading: Text("Vote average: ${film.voteAverage}"),
            ),
            ListTile(
              leading: Text("Popularity: ${film.popularity}"),
              trailing: Text("Votes:  ${film.voteCount}"),
            ),
            ListTile(
              leading: Text("Released: ${film.releaseDate}"),
            ),
          ],
        ).toList(),
      ),
      backgroundColor: Color(0xFFECEFF1),
    );
  }
}

class Film {
  int voteCount;
  var voteAverage;
  String title;
  double popularity;
  String posterPath;
  String originalLanguage;
  String backdropPath;
  String overview;
  String releaseDate;
}
//
//createGridView(BuildContext context, List<Results> filmsList) {
//  return
//}

/*
*
*
* ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: <Widget>[
//              Text(
//                "${film.title}",
//                style: TextStyle(fontSize: 22.0),
//              ),

                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Image.network(
                    'http://image.tmdb.org/t/p/w500${film.posterPath}',
                  ),
                ),
                Text(
                  "Popularity: ${film.popularity}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Release date: ${film.releaseDate}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Votes: ${film.voteCount}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Rate: ${film.voteAverage}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Overview: ${film.overview}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.justify,
                ),
                Text(
                  "Language: ${film.originalLanguage}",
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      )


      */
