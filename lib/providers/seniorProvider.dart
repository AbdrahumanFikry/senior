import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:senior/models/agentsModel.dart';
import 'package:senior/models/fieldForceSeniorTargetModel.dart';
import 'package:http/http.dart' as http;
import '../models/httpExceptionModel.dart';

class SeniorData with ChangeNotifier {
  FieldForceSeniorTargetModel fieldForceSeniorTarget;
  AgentsModel agents;

  //------------------------- Fetch senior target ------------------------------
  Future<void> fetchTargetSenior() async {
    const url = 'https://api.hmto-eleader.com/api/seniorFieldForce/analysis';
    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Response :" + responseData.toString());
        fieldForceSeniorTarget =
            FieldForceSeniorTargetModel.fromJson(responseData);
        notifyListeners();
        return true;
      } else {
        throw HttpException(message: responseData['error']);
      }
    } catch (error) {
      throw error;
    }
  }

  //---------------------------- Fetch Agents ----------------------------------
  Future<void> fetchAgents() async {
    const url = 'https://api.hmto-eleader.com/api/seniorFieldForce';
    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Response :" + responseData.toString());
        agents = AgentsModel.fromJson(responseData);
        notifyListeners();
        return true;
      } else {
        throw HttpException(message: responseData['error']);
      }
    } catch (error) {
      throw error;
    }
  }
}
