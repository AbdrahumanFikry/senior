import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:senior/models/answers.dart';
import 'package:senior/models/competitorPercent.dart';
import 'package:senior/models/qrResult.dart';
import 'package:senior/models/stores.dart';
import 'package:senior/models/target.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dataForNewShop.dart';
import '../models/httpExceptionModel.dart';

class FieldForceData with ChangeNotifier {
  String token;
  int userId;
  String userName;
  int businessId;
  String progress = '0';
  bool isLoading = false;

  void loading({bool state}) {
    isLoading = state;
    notifyListeners();
  }

  double maxValue = 100.0;
  var dio = Dio();
  DataForNewShop dataForNewShop;
  QrResult qrResult;
  List<Question> trueAndFalse;
  List<Question> longAnswerQuestion;
  List<Question> optionQuestion;
  List<Competitors> competitors = [];
  List<Question> products;
  List<CompetitorPercents> competitorsPercents = [];
  FieldForceStores fieldForceStores;
  List<StoresData> stores;
  TargetForceField target;
  List<Answer> questionsAnswer = new List<Answer>();

  //------------------------------  Add Answer ---------------------------------
  void addAnswer(Answer answer) {
    int index =
        questionsAnswer.indexWhere((i) => i.questionId == answer.questionId);
    if (index != -1) {
      questionsAnswer[index].answer = answer.answer;
    } else {
      questionsAnswer.add(answer);
    }
    notifyListeners();
  }

  //--------------------------- Fetch questions --------------------------------
  Future<void> fetchQuestions() async {
    const url = 'https://api.hmto-eleader.com/api/newStore';
    // try {
    await fetchUserData();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    print("Response :" + response.body.toString());
    final Map responseData = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      dataForNewShop = DataForNewShop.fromJson(responseData);
      competitors = dataForNewShop.data.competitors;
      final List<CompetitorPercents> loadedItems = [];
      competitors.forEach((competitor) {
        loadedItems.add(
          CompetitorPercents(
            competitorId: competitor.competitorId,
            sallesRateStock: '0.0',
            sallesRateMoney: '0',
          ),
        );
      });
      competitorsPercents = loadedItems;
      trueAndFalse = dataForNewShop.data.question
          .where((i) => i.type == 'falseOrTrue')
          .toList();
      longAnswerQuestion = dataForNewShop.data.question
          .where((i) => i.type == 'typing')
          .toList();
      optionQuestion = dataForNewShop.data.question
          .where((i) => i.type == 'options')
          .toList();
      products = dataForNewShop.data.question
          .where((i) => i.type == 'product')
          .toList();
      notifyListeners();
      return true;
    } else {
      throw HttpException(message: responseData['error']);
    }
    // } catch (error) {
    //   print('Request Error :' + error.toString());
    //   throw error;
    // }
  }

  //----------------------------- Add new shop ---------------------------------
  Future<void> addNewShop({
    String shopName,
    String customerName,
    String customerPhone,
    String sellsName,
    String sellsPhone,
    String country,
    String city,
    String state,
    double rate,
    String lat,
    String long,
    File image1,
    File image2,
    File image3,
    File image4,
    String landmark,
    String position,
    String answers,
//    String competitorsData,
  }) async {
    await fetchUserData();
    const url = 'https://api.hmto-eleader.com/api/add_field_force_shop';
    try {
      print('Request Body : '
          '\n$shopName\n$customerName\n$customerPhone\n$sellsName\n$sellsPhone\n'
          '$rate\n$answers\n${json.encode({
        "data": competitorsPercents
      })}\n$lat\n$long\n$landmark\n$position\n$businessId\n$userId\n$image1\n$image2\n$image3\n$image4');
      var formData = FormData();
      formData.fields..add(MapEntry('business_id', businessId.toString()));
      formData.fields..add(MapEntry('supplier_business_name', shopName));
      formData.fields..add(MapEntry('name', customerName));
      formData.fields..add(MapEntry('mobile', customerPhone));
      formData.fields..add(MapEntry('alternate_name', sellsName));
      formData.fields..add(MapEntry('alternate_number', sellsPhone));
      formData.fields..add(MapEntry('country', country));
      formData.fields..add(MapEntry('city', city));
      formData.fields..add(MapEntry('state', state));
      formData.fields..add(MapEntry('lat', lat));
      formData.fields..add(MapEntry('long', long));
      formData.fields..add(MapEntry('rate', rate.toString()));
      if (image1 != null)
        formData.files.add(MapEntry(
          'image_in',
          await MultipartFile.fromFile(image1.path,
              filename: image1.path.split("/").last),
        ));
      if (image2 != null)
        formData.files.add(MapEntry(
          'image_out',
          await MultipartFile.fromFile(image2.path,
              filename: image2.path.split("/").last),
        ));
      if (image3 != null)
        formData.files.add(MapEntry(
          'image_storeAds',
          await MultipartFile.fromFile(image3.path,
              filename: image3.path.split("/").last),
        ));
      if (image4 != null)
        formData.files.add(MapEntry(
          'image_storeFront',
          await MultipartFile.fromFile(image4.path,
              filename: image4.path.split("/").last),
        ));
      formData.fields..add(MapEntry('landmark', landmark));
      formData.fields..add(MapEntry('position', position));
//      formData.fields..add(MapEntry('created_by', userId.toString()));
      formData.fields..add(MapEntry('questionsAnswer', answers));
      formData.fields
        ..add(MapEntry(
            'competitors', json.encode({"data": competitorsPercents})));
      var response = await dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          progress = (sent / total * 100).toStringAsFixed(0);
          print(progress);
          notifyListeners();
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
//            followRedirects: false,
//            validateStatus: (status) {
//              return status == 500;
//            },
        ),
      );
      print("Response :" + response.toString());
      notifyListeners();
      competitorsPercents = [];
      questionsAnswer = [];
      maxValue = 100;
      dataForNewShop = null;
      stores = null;
      return true;
    } catch (error) {
      print('Request Error :' + error.toString());
      if (!error.toString().contains(
          'DioError [DioErrorType.DEFAULT]: FormatException: Unexpected character (at character 1)')) {
        throw error;
      }
      print('Request Error :' + error.toString());
    }
  }

  //----------------------------- Fetch Data -----------------------------------
  Future<bool> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    token = extractedUserData['token'];
    userId = extractedUserData['userId'];
    businessId = extractedUserData['businessId'];
    userName = extractedUserData['userName'];
    notifyListeners();
    return true;
  }

  //------------------------------ Qr reader -----------------------------------
  Future<void> qrReader({String qrData}) async {
    const url = 'https://api.hmto-eleader.com/api/store/visited';
    await fetchUserData();
    try {
      var body = json.encode({
        "qrcode": "$qrData",
      });

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        url,
        body: body,
        headers: headers,
      );
      print("Response :" + response.body.toString());
      final Map responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.contains('401')) {
          throw HttpException(message: ' هذا المتجر ليس ضمن التارجت المحقق لك');
        }
        qrResult = QrResult.fromJson(responseData);
        competitors = qrResult.competitors;
        final List<CompetitorPercents> loadedItems = [];
        competitors.forEach((competitor) {
          loadedItems.add(
            CompetitorPercents(
              competitorId: competitor.competitorId,
              sallesRateStock: '0',
              sallesRateMoney: '0.0',
            ),
          );
        });
        competitorsPercents = loadedItems;
        trueAndFalse =
            qrResult.question.where((i) => i.type == 'falseOrTrue').toList();
        longAnswerQuestion =
            qrResult.question.where((i) => i.type == 'typing').toList();
        optionQuestion =
            qrResult.question.where((i) => i.type == 'options').toList();
        products = qrResult.question.where((i) => i.type == 'product').toList();
        notifyListeners();
        return true;
      } else {
        throw HttpException(message: responseData['message']);
      }
    } catch (error) {
      print('Request Error :' + error.toString());
      throw error;
    }
  }

  //----------------------------- Fetch stores ---------------------------------
  Future<void> fetchStores() async {
    await fetchUserData();
    stores = null;
    final url = 'https://api.hmto-eleader.com/api/targetStore';
    try {
      final response = await http.get(url, headers: {
        'Accept': 'json',
        'Authorization': 'Bearer $token',
      });
      print("Response :" + response.body.toString());
      final Map responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        fieldForceStores = FieldForceStores.fromJson(responseData);
        stores = fieldForceStores.ownStores + fieldForceStores.storeVisit;
        return true;
      } else {
        throw HttpException(message: responseData['error']);
      }
    } catch (error) {
      print('Request Error :' + error.toString());
      throw error;
    }
  }

  //--------------------------- Change percents --------------------------------
  void changePercent({
    int id,
    String percent,
    String amount,
  }) async {
    final index = competitorsPercents.indexWhere(
      (item) => item.competitorId == id,
    );
    if (index != -1) {
      competitorsPercents[index].sallesRateStock = percent;
      competitorsPercents[index].sallesRateMoney = amount;
    } else {
      competitorsPercents.add(
        CompetitorPercents(
          competitorId: id,
          sallesRateStock: percent,
          sallesRateMoney: amount,
        ),
      );
    }
    double sum = 0;
    competitorsPercents.forEach((competitor) {
      sum = sum + double.tryParse(competitor.sallesRateStock);
    });
    maxValue = 100.0 - sum;
    notifyListeners();
  }

  //----------------------------- Add new visit --------------------------------
//   Future<void> addNewVisit({
//     int id,
//     String answers,
//   }) async {
//     await fetchUserData();
//     const url = 'https://api.hmto-eleader.com/api/addnewvisit';
//     try {
//       var body = {
//         "contact_id": id.toString(),
//         "business_id": "$businessId",
// //        "created_by": "$userId",
//         "questionsAnswer": answers,
//         "competitors": json.encode({"data": competitorsPercents}),
//       };
//
//       Map<String, String> headers = {
//         'Authorization': 'Bearer $token',
//       };
//       await fetchUserData();
//       final response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );
//       print("Response :" + response.body.toString());
//       final Map responseData = json.decode(response.body);
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         stores = null;
//         questionsAnswer = [];
//         notifyListeners();
//         return true;
//       } else {
//         throw HttpException(message: responseData['error']);
//       }
//     } catch (error) {
//       print('Request Error :' + error.toString());
//       throw error;
//     }
//   }

  Future<void> addNewVisit({
    int id,
    String answers,
    File image1,
    File image2,
    File image3,
    File image4,
    double lat,
    double lang,
  }) async {
    await fetchUserData();
    const url = 'https://api.hmto-eleader.com/api/addnewvisit';
    try {
      var formData = FormData();
      formData.fields..add(MapEntry('contact_id', id.toString()));
      formData.fields..add(MapEntry('business_id', "$businessId"));
      formData.fields..add(MapEntry('created_by', "$userId"));
      formData.fields..add(MapEntry('questionsAnswer', answers));
      formData.fields
        ..add(MapEntry(
            'competitors', json.encode({"data": competitorsPercents})));
      if (image1 != null)
        formData.files.add(MapEntry(
          'image_in',
          await MultipartFile.fromFile(image1.path,
              filename: image1.path.split("/").last),
        ));
      if (image2 != null)
        formData.files.add(MapEntry(
          'image_out',
          await MultipartFile.fromFile(image2.path,
              filename: image2.path.split("/").last),
        ));
      if (image3 != null)
        formData.files.add(MapEntry(
          'image_storeAds',
          await MultipartFile.fromFile(image3.path,
              filename: image3.path.split("/").last),
        ));
      if (image4 != null)
        formData.files.add(MapEntry(
          'image_storeFront',
          await MultipartFile.fromFile(image4.path,
              filename: image4.path.split("/").last),
        ));
      formData.fields
        ..add(MapEntry(
          'lat',
          lat.toString(),
        ));
      formData.fields..add(MapEntry('lan', lang.toString()));
      formData.fields..add(MapEntry('lng', lang.toString()));
      var response = await dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          notifyListeners();
        },
        options: Options(
          headers: {
            // 'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print("Response :" + response.toString());
      stores = null;
      questionsAnswer = [];
      notifyListeners();
      return true;
    } catch (error) {
      print('Request Error :' + error.toString());
      if (!error.toString().contains(
          'DioError [DioErrorType.DEFAULT]: FormatException: Unexpected character (at character 1)')) {
        throw error;
      }
      print('Request Error :' + error.toString());
    }
  }

  //---------------------------- Fetch Target ----------------------------------
  Future<void> fetchTarget() async {
    await fetchUserData();
    final url = 'https://api.hmto-eleader.com/api/analysis';
    try {
      final response = await http.get(url, headers: {
//        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print("Response :" + response.body.toString());
      final Map responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        target = TargetForceField.fromJson(responseData);
        return true;
      } else {
        throw HttpException(message: responseData['error']);
      }
    } catch (error) {
      print('Request Error :' + error.toString());
      throw error;
    }
  }

  //---------------------------- Fetch Target ----------------------------------
  Future<void> closeVisit({String answer, int id}) async {
    await fetchUserData();
    loading(state: true);
    final url = 'https://api.hmto-eleader.com/api/shop/close';
    try {
      var body = {
        "contact_id": id.toString(),
        "business_id": "$businessId",
        "answer": answer,
      };

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      print("Response :" + response.body.toString());
      final Map responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        loading(state: false);

        return true;
      } else {
        loading(state: false);

        throw HttpException(message: responseData['error']);
      }
    } catch (error) {
      loading(state: false);

      print('Request Error :' + error.toString());
      throw error;
    }
  }
}
