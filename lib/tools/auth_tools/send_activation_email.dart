import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class SendActivationEmail {
  sendEmail({
    required String recipientEmail,
    required String activationLink,
  }) async {
    String username = 'bhuwancnx23@gmail.com';
    String password = 'honeyM00n@cr7';

    final smtpServer = gmail(username, password);

    // Create our message.
    final message = Message()
      ..from = Address(username, 'Safely Net')
      ..recipients.add(recipientEmail)
      ..subject = 'Activate your account'
      ..text =
          'Please click the activate account button to activate your account'
      ..html = '''
      <p>Please click the activate account button to activate your account:</p>
      <br>
      <br>
      <a href="$activationLink"> <button type="button">
          Activate</button> </a>''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.' + e.toString());
    }

    var connection = PersistentConnection(smtpServer);

    await connection.send(message);

    await connection.close();
  }
}
