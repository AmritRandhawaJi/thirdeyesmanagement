import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SendMessageCloud{
 static void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAYpfZcHA:APA91bF0WfUYVS_3W_CXu5szD_YSqTAoEGA00IhFbgH_io3WV_PBjhjNuIwRJuOXFc1rmrFvY1LVjohVvCMM-sn4EnKepPHX0fQ0u1pPWUGCfi7PeBofCajWbWtMTqWWMjqaJ4_pWfCh',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title
            },
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': "Sales"
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("error push notification");
      }
    }
  }
}