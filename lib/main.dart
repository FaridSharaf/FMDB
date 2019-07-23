import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'FilmResponse.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
//      title: "fmdb",
//      color: Colors.blueAccent,
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
  List<Results> filmsList = List();

  int voteCount;
  var voteAverage;
  String title;
  double popularity;
  String posterPath;
  String originalLanguage;
  String backdropPath;
  String overview;
  String releaseDate;

  Future<Response> fetchFilm() async {
    final response = await get(
        "https://api.themoviedb.org/3/movie/popular?api_key=d032214048c9ca94d788dcf68434f385");
    var jsonString = response.body;
    var parseJson = json.decode(jsonString);
    var filmResponse = Films.fromJson(parseJson);

    setState(() {
      for (int i = 0; i < 20; i++) {
        voteCount = filmResponse.results[i].voteCount;
        voteAverage = filmResponse.results[i].voteAverage;
        title = filmResponse.results[i].title;
        popularity = filmResponse.results[i].popularity;
        posterPath =
            "http://image.tmdb.org/t/p/w500/${filmResponse.results[i].posterPath}";
        backdropPath =
            "http://image.tmdb.org/t/p/w500/${filmResponse.results[i].backdropPath}";
        originalLanguage = filmResponse.results[i].originalLanguage;
        releaseDate = filmResponse.results[i].releaseDate;
        overview = filmResponse.results[i].overview;

        Results film = Results(
          posterPath: this.posterPath,
          title: this.title,
          backdropPath: this.backdropPath,
          originalLanguage: this.originalLanguage,
          overview: this.overview,
          voteAverage: this.voteAverage,
          voteCount: this.voteCount,
          popularity: this.popularity,
          releaseDate: this.releaseDate,
        );
        filmsList.add(film);
      }
    });
  }

//  @override
//  void initState() {
//    super.initState();
//
//
//  }

  @override
  Widget build(BuildContext context) {
    fetchFilm();
    return Scaffold(
      appBar: AppBar(
        title: Text("First screen"),
        backgroundColor: Colors.white,
        leading: Icon(
          (Icons.video_library),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 10 / 16,
        children: List.generate(
          filmsList.length,
          (index) {
            return Container(
              padding: EdgeInsets.all(5.0),
              child: FlatButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    FilmData.filmDataRoute,
                    arguments: Results(
                      posterPath: filmsList[index].posterPath,
                      title: filmsList[index].title,
                      backdropPath: filmsList[index].backdropPath,
                      originalLanguage: filmsList[index].originalLanguage,
                      overview: filmsList[index].overview,
                      voteAverage: filmsList[index].voteAverage,
                      voteCount: filmsList[index].voteCount,
                      popularity: filmsList[index].popularity,
                      releaseDate: filmsList[index].releaseDate,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "${filmsList[index].title}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Image.network(
                        filmsList[index].posterPath,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
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
    Results results = ModalRoute.of(context).settings.arguments;
//
//    Widget testBGCarousel = new Container(
//      child: new CarouselSlider(
//        items: <Widget>[
//          Image.network(results.posterPath),
//          Image.network(results.backdropPath),
//        ]
//            .map((bgImg) =>
//                new Image(width: 1500.0, height: 1500.0, fit: BoxFit.cover))
//            .toList(),
//        autoPlayAnimationDuration: Duration(seconds: 2),
//      ),
//    );

    return Scaffold(
        appBar: AppBar(
          title: Text("${results.title}"),
          backgroundColor: Colors.white,
          leading: Icon((Icons.movie)),
        ),
        body: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "${results.title}",
                  style: TextStyle(fontSize: 22.0),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Image.network(results.posterPath)),
                Text(
                  "Popularity: ${results.popularity}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Release date: ${results.releaseDate}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Votes: ${results.voteCount}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Rate: ${results.voteAverage}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Overview: ${results.overview}",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.justify,
                ),
                Text(
                  "Language: ${results.originalLanguage}",
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ],
        ));
  }
}
//
//createGridView(BuildContext context, List<Results> filmsList) {
//  return
//}
