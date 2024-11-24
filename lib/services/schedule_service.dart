// import 'package:ct484_project/models/schedule.dart';
// import 'package:ct484_project/services/pocketbase_client.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:pocketbase/pocketbase.dart';
// import '../models/user.dart';
// import 'pocketbase_client.dart';

// class ScheduleService {
//   Future<String> addSchedule(Map<String,dynamic> tripData) async {
//     final pb = await getPocketbaseInstance();
//     try {
//       final record = await pb.collection('schedule').create(
//         body: {
//           'name': tripData['name'],
//           'userId': pb.authStore.model!.id,
//           'startDate': tripData['startDate'], 
//           'endDate': tripData['endDate'], 
//           'budget': tripData['budget'],
//           'destination': tripData['destination']
//         },
//         files: [
//           http.MultipartFile.fromBytes(
//             'image',
//             await tripData['image'].readAsBytes(), 
//             filename: tripData['image'].uri.pathSegments.last,
//           ),
//         ]
//       );
//       return record.id;
//     } catch (error) {
//       print(error);
//       if (error is ClientException){
//         throw Exception(error.response['message']);
//       }
//       throw Exception('An error occurred');
//     }
//   }
//   Future<void> addSchedulePlan(Map<String,dynamic> tripData, Map<int, List<Map<String, String>>> placesByDay,) async {
//     final pb = await getPocketbaseInstance();
//     try {
//       String scheduleId = await addSchedule(tripData);
//       DateTime startDate = DateTime.parse(tripData['startDate']);
//       DateTime endDate = DateTime.parse(tripData['endDate']);

//       for (DateTime current = startDate; current.isBefore(endDate) || current.isAtSameMomentAs(endDate); 
//         current = current.add(Duration(days: 1))) {
//           final day= current.difference(startDate).inDays;
//           final placeListId =[];
//           for(int i=0; i< placesByDay[day]!.length; i++){
//             placeListId.add(placesByDay[day]![i]['id']);
//           }
//           pb.collection('schedule_details').create(
//             body: {
//               'scheduleId': scheduleId,
//               'placeListId': placeListId,
//               'Day': current.toIso8601String()
//             }
//           );
//       }
//     } catch (error) {
//       if (error is ClientException){
//         throw Exception(error.response['message']);
//       }
//       throw Exception('An error occurred');
//     }
//   }

//   Future<List<Schedule>> fetchSchedule() async {
//     final pb = await getPocketbaseInstance();
//     final List<Schedule> schedules = [];
//     try {
//       final userId = pb.authStore.model.id;
//       final scheduleModels = await pb.collection('schedule').getFullList(
//         filter: 'userId="$userId"'
//       );
//       for (final scheduleModel in scheduleModels) {
//         schedules.add(
//           Schedule.fromJson(
//             scheduleModel.toJson()
//               ..addAll(
//                 {   
//                     'imageUrl': pb.files.getUrl(scheduleModel, scheduleModel.getStringValue('image')).toString(),
//                 },
//               ),
//           ),
//         );
//       }
//       return schedules;
//     } catch (error) {
//       if (error is ClientException){
//         throw Exception(error.response['message']);
//       }
//       throw Exception('An error occurred');
//     }
//   }
//   Future<List<Schedule>> fetchPastTrips() async {
//     final pb = await getPocketbaseInstance();
//     final List<Schedule> pastTrips = [];
//     try {
//       final userId = pb.authStore.model.id;
//       final scheduleModels = await pb.collection('schedule').getFullList(
//         filter: 'userId="$userId"'
//       );
//       final currentDate = DateTime.now();
//       for (final scheduleModel in scheduleModels) {
//         DateTime endDate = DateTime.parse(scheduleModel.getStringValue('endDate'));
//         if (endDate.isBefore(currentDate)) {
//           pastTrips.add(
//             Schedule.fromJson(
//               scheduleModel.toJson()
//                 ..addAll({
//                   'imageUrl': pb.files.getUrl(scheduleModel, scheduleModel.getStringValue('image')).toString(),
//                 }),
//             ),
//           );
//         }
//       }
//       return pastTrips;
//     } catch (error) {
//       if (error is ClientException) {
//         throw Exception(error.response['message']);
//       }
//       throw Exception('An error occurred');
//     }
//   }

//   Future<List<Schedule>> fetchOngoingTrips() async {
//     final pb = await getPocketbaseInstance();
//     final List<Schedule> ongoingTrips = [];
//     try {
//       final userId = pb.authStore.model.id;
//       final scheduleModels = await pb.collection('schedule').getFullList(
//         filter: 'userId="$userId"'
//       );

//       final currentDate = DateTime.now();

//       for (final scheduleModel in scheduleModels) {
//         DateTime startDate = DateTime.parse(scheduleModel.getStringValue('startDate'));
//         DateTime endDate = DateTime.parse(scheduleModel.getStringValue('endDate'));

//         if (endDate.isAfter(currentDate)) {
//           ongoingTrips.add(
//             Schedule.fromJson(
//               scheduleModel.toJson()
//                 ..addAll({
//                   'imageUrl': pb.files.getUrl(scheduleModel, scheduleModel.getStringValue('image')).toString(),
//                 }),
//             ),
//           );
//         }
//       }
//       return ongoingTrips;
//     } catch (error) {
//       if (error is ClientException) {
//         throw Exception(error.response['message']);
//       }
//       throw Exception('An error occurred');
//     }
//   }
//   Future<Map<int, List<Map<String, String>>>> fetchScheduleDetails(String scheduleId) async {
//     final pb = await getPocketbaseInstance();
//     final Map<int, List<Map<String, String>>> scheduleDetails = {};

//     try {
//       final scheduleDetailsModels = await pb.collection('schedule_details').getFullList(
//         filter: 'scheduleId="$scheduleId"',
//       );
//       for (final scheduleDetailModel in scheduleDetailsModels) {
//         final detail = scheduleDetailModel.toJson();
//         final dayIndex = DateTime.parse(detail['Day']).day; 
//         if (!scheduleDetails.containsKey(dayIndex)) {
//           scheduleDetails[dayIndex] = [];
//         }
//         scheduleDetails[dayIndex]?.add({
//           'id': detail['id'],
//           'placeListId': detail['placeListId'].toString(), 
//           'Day': detail['Day'],
//         });
//       }
//       return scheduleDetails;
//     } catch (error) {
//       print(error);
//       if (error is ClientException) {
//         throw Exception(error.response['message']);
//       }
//       throw Exception('An error occurred while fetching schedule details');
//     }
//   }

//   Future<void> deleteSchedule(String scheduleId) async {
//     final pb = await getPocketbaseInstance();
//     try {
//       final scheduleDetails = await pb.collection('schedule_details').getFullList(
//         filter: 'scheduleId="$scheduleId"',
//       );

//       for (final detail in scheduleDetails) {
//         await pb.collection('schedule_details').delete(detail.id);
//       }

//       await pb.collection('schedule').delete(scheduleId);
//     } catch (error) {
//       print(error);
//       if (error is ClientException) {
//         throw Exception(error.response['message']);
//       }
//       throw Exception('An error occurred while deleting the schedule');
//     }
//   }


// }