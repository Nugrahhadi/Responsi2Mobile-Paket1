import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_exception.dart';
import 'user_info.dart';

class Api {
  Future<dynamic> post(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    
    print("===========================================");
    print("POST Request ke: $url");
    print("Data Mentah: $data");
    print("Token: $token");
    print("===========================================");

    dynamic responseJson;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          'Host': 'Responsi_2_Mobile.test',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("===========================================");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("===========================================");

      responseJson = _returnResponse(response);
    } catch (e) {
      print("===========================================");
      print("ERROR POST: $e");
      print("===========================================");
      rethrow;
    }
    return responseJson;
  }

  Future<dynamic> get(String url) async {
    var token = await UserInfo().getToken();
    
    print("===========================================");
    print("GET Request ke: $url");
    print("Token: $token");
    print("===========================================");

    dynamic responseJson;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Host': 'Responsi_2_Mobile.test',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("===========================================");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("===========================================");

      responseJson = _returnResponse(response);
    } catch (e) {
      print("===========================================");
      print("ERROR GET: $e");
      print("===========================================");
      rethrow;
    }
    return responseJson;
  }

  Future<dynamic> put(String url, dynamic data) async {
    var token = await UserInfo().getToken();
    
    print("===========================================");
    print("PUT Request ke: $url");
    print("Data Mentah: $data");
    print("Token: $token");
    print("===========================================");

    dynamic responseJson;
    try {
      final response = await http.put(
        Uri.parse(url),
        body: data,
        headers: {
          'Host': 'Responsi_2_Mobile.test',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("===========================================");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("===========================================");

      responseJson = _returnResponse(response);
    } catch (e) {
      print("===========================================");
      print("ERROR PUT: $e");
      print("===========================================");
      rethrow;
    }
    return responseJson;
  }

  Future<dynamic> delete(String url) async {
    var token = await UserInfo().getToken();
    
    print("===========================================");
    print("DELETE Request ke: $url");
    print("Token: $token");
    print("===========================================");

    dynamic responseJson;
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Host': 'Responsi_2_Mobile.test',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("===========================================");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("===========================================");

      responseJson = _returnResponse(response);
    } catch (e) {
      print("===========================================");
      print("ERROR DELETE: $e");
      print("===========================================");
      rethrow;
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          var responseJson = json.decode(response.body);
          print("===========================================");
          print("PARSED RESPONSE: $responseJson");
          print("===========================================");
          return responseJson;
        } catch (e) {
          print("===========================================");
          print("ERROR PARSING JSON: $e");
          print("Raw Body: ${response.body}");
          print("===========================================");
          rethrow;
        }
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 422:
        throw UnprocessableEntityException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
          'Error terjadi saat komunikasi dengan Server dengan kode status: ${response.statusCode}',
        );
    }
  }
}
