import 'package:OnceWing/models/game_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GroupDatabaseService {
  final String groupid;
  GroupDatabaseService({this.groupid});

  var uuid = Uuid().v1();

  // collection reference
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('Groups');

  Future registerGroup(String groupName, String type, String bio,
      List<dynamic> uids, List<dynamic> managers, Map registration) async {
    try {
      await updateGroupData(
          groupName, uuid, type, bio, [], uids, managers, registration);
      return uuid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future updateGroupData(
    String groupName,
    String groupId,
    String type,
    String bio,
    List<dynamic> gameids,
    List<dynamic> uids,
    List<dynamic> managers,
    Map registration,
  ) async {
    return await groupCollection.doc(groupId).set({
      'groupName': groupName,
      'groupid': groupId,
      'type': type,
      'bio': bio,
      'gameids': gameids,
      'uids': uids,
      'managers': managers,
      'registration': registration
    });
  }

  // Group list from snapshot
  List<GroupData> _groupListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return GroupData(
        groupName: data['groupName'] ?? '',
        groupId: data['groupid'] ?? '',
        type: data['type'] ?? '',
        bio: data['bio'] ?? '',
        gameids: data['gameids'] ?? [],
        uids: data['uids'] ?? [],
        managers: data['managers'] ?? [],
        registration: data['registration'] ?? {},
      );
    }).toList();
  }

  // userData from snapshot
  GroupData _groupDataFromSnapshot(DocumentSnapshot snapshot) {
    return GroupData();
  }

  // Get profile stream
  Stream<List<GroupData>> get groupDatas {
    return groupCollection.snapshots().map(_groupListFromSnapshot);
  }

  // get user doc stream
  Stream<GroupData> get groupData {
    return groupCollection
        .doc(groupid)
        .snapshots()
        .map(_groupDataFromSnapshot);
  }
}
