import 'package:OnceWing/models/game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GameDatabaseService {
  final String gameid;
  GameDatabaseService({this.gameid});

  var uuid = Uuid().v1();

  // collection reference
  final CollectionReference gameCollection =
      FirebaseFirestore.instance.collection('games');

  Future registerGame(List<String> uids, String type, Map games, String groupId,
      int numOfRound, int numOfCourts) async {
    try {
      await updateGameData(uuid, uids, type, groupId, numOfRound, games,
          DateTime.now(), true, numOfCourts, {}, {}, {});
      return uuid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future updateGameData(
      String gameid,
      List<String> uids,
      String type,
      String groupId,
      int round,
      Map scores,
      DateTime date,
      bool live,
      int numOfCourts,
      Map upcomingGames,
      Map finishedGames,
      Map inGame) async {
    return await gameCollection.doc(gameid).set({
      'gameid': gameid,
      'uids': uids,
      'type': type,
      'groupId': groupId,
      'round': round,
      'scores': scores,
      'date': date,
      'live': live,
      'numOfCourts': numOfCourts,
      'upcomingGames': upcomingGames,
      'finishedGames': finishedGames,
      'inGame': inGame
    });
  }

  // prof list from snapshot
  List<GameData> _gameListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return GameData(
          gameid: data['gameid'] ?? '',
          uids: data['uids'] ?? ['s'],
          type: data['type'] ?? 'Friendly',
          groupId: data['groupId'] ?? '',
          round: data['round'] ?? 0,
          scores: data['scores'] ?? {},
          date: (data['date'] as Timestamp).toDate() ?? DateTime.now(),
          live: data['live'] ?? false,
          numOfCourts: data['numOfCourts'] ?? [],
          upcomingGames: data['upcomingGames'] ?? [],
          finishedGames: data['finishedGames'] ?? [],
          inGame: data['inGame'] ?? []);
    }).toList();
  }

  // userData from snapshot
  GameData _gameDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return GameData(
        gameid: gameid,
        uids: data['uids'],
        type: data['type'],
        groupId: data['groupId'],
        round: data['round'],
        scores: data['scores'],
        date: (data['date'] as Timestamp).toDate(),
        live: data['live'],
        numOfCourts: data['numOfCourts'],
        upcomingGames: data['upcomingGames'] ?? [],
        finishedGames: data['finishedGames'] ?? [],
        inGame: data['inGame'] ?? []);
  }

  // Get profile stream
  Stream<List<GameData>> get gameDatas {
    return gameCollection.snapshots().map(_gameListFromSnapshot);
  }

  // get user doc stream
  Stream<GameData> get gameData {
    return gameCollection.doc(gameid).snapshots().map(_gameDataFromSnapshot);
  }
}
