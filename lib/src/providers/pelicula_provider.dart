import 'dart:async';
import 'dart:convert';
import 'package:apppeliculas/src/models/actores_model.dart';
import 'package:http/http.dart' as http;
import 'package:apppeliculas/src/models/pelicula_model.dart';

class PeliculasProvider {
  String _apikey = 'b39da464a6b1510ce0b0cc170bffdd72';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';
  int _popularPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();
  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;
  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStream() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key': _apikey,
      'languaje': _language,
    });

    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);

    final peliculas = new Peliculas.fromJsonList(decodeData['results']);
    //print(peliculas.items[1].title);
    return peliculas.items;
  }

  Future<List<Pelicula>> getPopulares() async {
    if (_cargando) return [];
    _cargando = true;

    _popularPage++;

    //print('los siguientes ....');
    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apikey,
      'languaje': _language,
      'page': _popularPage.toString()
    });

    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);
    final peliculas = new Peliculas.fromJsonList(decodeData['results']);
    _populares.addAll(peliculas.items);
    popularesSink(_populares);
    //print(peliculas.items[1].title);
    _cargando = false;
    return peliculas.items;
  }

  Future<List<Actor>> getCast(String peliId) async {
    final url = Uri.https(_url, '3/movie/$peliId/credits',
        {'api_key': _apikey, 'language': _language});

    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);

    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actores;
  }

  Future<List<Pelicula>> buscarPeliculas(String _query) async {
    final url = Uri.https(_url, '3/search/movie',
        {'api_key': _apikey, 'languaje': _language, 'query': _query});
    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);

    final peliculas = new Peliculas.fromJsonList(decodeData['results']);
    //print(peliculas.items[1].title);
    return peliculas.items;
  }
}
