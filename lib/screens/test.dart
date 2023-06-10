import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class Test {
  late TwilioFlutter twilioFlutter;

  FirebaseFirestore db = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> dataList = [];

  final String _accountSID = "AC34d1677ab2338063335ffb3944f73760";
  final String _authToken = "d61804d33ebed647050bf9546813c8c3";
  final String _number = "+15075435044";

  Future<void> updateClients() async {
    twilioFlutter = TwilioFlutter(
        accountSid: _accountSID, authToken: _authToken, twilioNumber: _number);
    await db
        .collection("clients")
        .where("pendingMassage", isLessThanOrEqualTo: 2)
        .get()
        .then((value) => {
              if (value.size != 0) {dataList = value.docs, notifyAll()}
            });
  }

  notifyAll() {
    for (var element in dataList) {
      if (!element["notify"]) {
        String number = element["phone"];
        twilioFlutter.sendSMS(
            toNumber: "+91$number",
            messageBody:
                "Your membership is going to expire soon please visit to renew we have exciting offers for you.");
      }
    }
  }
}
