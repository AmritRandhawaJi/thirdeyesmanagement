import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thirdeyesmanagement/modal/twilio.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class Test {
  late TwilioFlutter twilioFlutter;

  FirebaseFirestore db = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> dataList = [];

  Future<void> updateClients() async {
    twilioFlutter = TwilioFlutter(
        accountSid: Twilio.accountSID,
        authToken: Twilio.authToken,
        twilioNumber: Twilio.number);
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
      String number = element["phone"];
      twilioFlutter.sendSMS(
          toNumber: "+91$number",
          messageBody:
              "Your membership is going to expire soon please visit to renew we have exciting offers for you.");
    }
  }
}
