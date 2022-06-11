import 'package:OnceWing/models/profile.dart';
import 'package:OnceWing/models/user.dart';
import 'package:OnceWing/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  var _auth = AuthService();

  // collection reference
  final CollectionReference profCollection =
      FirebaseFirestore.instance.collection('profiles');

  Future updateUserData(
    String uid,
    String clan,
    String name,
    int rank,
    List<dynamic> eights,
    int gamesPlayed,
    String status,
    int wins,
    String photoUrl,
    int exp,
    String fcmToken,
    int fireRating,
    int waterRating,
    int windRating,
    int earthRating,
    Map raters,
    int feathers,
    List<dynamic> collection,
    String bio,
    String email,
    Map followers,
    Map following,
  ) async {
    return await profCollection.doc(uid).set({
      'uid': uid,
      'clan': clan,
      'name': name,
      'rank': rank,
      'eights': eights,
      'gamesPlayed': gamesPlayed,
      'status': status,
      'wins': wins,
      'photoUrl': photoUrl,
      'exp': exp,
      'fcmToken': fcmToken,
      'fireRating': fireRating,
      'waterRating': waterRating,
      'windRating': windRating,
      'earthRating': earthRating,
      'raters': raters,
      'feathers': feathers,
      'collection': collection,
      'bio': bio,
      'email': email,
      'followers': followers,
      'following': following,
    });
  }

  // prof list from snapshot
  List<Profile> _profileListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Profile(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        clan: data['clan'] ?? '',
        rank: data['rank'] ?? -1,
        eights: data['eights'] ?? [0, 0, 0, 0, 0, 0, 0],
        gamesPlayed: data['gamesPlayed'] ?? -1.0,
        status: data['status'] ?? '',
        wins: data['wins'] ?? 0,
        photoUrl: data['photoUrl'] ?? '',
        exp: data['exp'] ?? 0,
        fcmToken: data['fcmToken'] ?? '',
        fireRating: data['fireRating'] ?? 0,
        waterRating: data['waterRating'] ?? 0,
        windRating: data['windRating'] ?? 0,
        earthRating: data['earthRating'] ?? 0,
        raters: data['raters'] ?? {},
        feathers: data['feathers'] ?? 0,
        collection: data['collections'] ?? [],
        bio: data['bio'] ?? '',
        email: data['email'] ?? '',
        followers: data['followers'] ?? {},
        following: data['following'] ?? {},
      );
    }).toList();
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserData(
      uid: uid ?? '',
      name: data['name'] ?? '',
      clan: data['clan'] ?? '',
      rank: data['rank'] ?? 0.0,
      eights: data['eights'] ?? [],
      gamesPlayed: data['gamesPlayed'] ?? 0,
      status: data['status'] ?? '',
      wins: data['wins'] ?? 0,
      photoUrl: data['photoUrl'] ?? '',
      exp: data['exp'] ?? 0,
      fcmToken: data['fcmToken'] ?? '',
      fireRating: data['fireRating'] ?? 0,
      waterRating: data['waterRating'] ?? 0,
      windRating: data['windRating'] ?? 0,
      earthRating: data['earthRating'] ?? 0,
      raters: data['raters'] ?? {},
      feathers: data['feathers'] ?? 0,
      collection: data['collections'] ?? [],
      bio: data['bio'] ?? '',
      email: data['email'] ?? '',
      followers: data['followers'] ?? {},
      following: data['following'] ?? {},
    );
  }

  // Get profile stream
  Stream<List<Profile>> get profiles {
    return profCollection.snapshots().map(_profileListFromSnapshot);
  }

  // get user doc stream
  Stream<UserData> get userData {
    Stream<UserData> ud;

    void _checkFirebase() async {
      try {
        ud = profCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
      } catch (e) {
        _auth.signOut();
        ud = null;
        print(e.toString());
      }
    }

    _checkFirebase();

    return ud;
  }
}
