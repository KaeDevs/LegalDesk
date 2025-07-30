import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/client_model.dart';
import '../../utils/font_styles.dart';

class ClientDetailView extends StatelessWidget {
  final ClientModel client;

  const ClientDetailView({super.key, required this.client});

  void _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch phone call');
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              client.name,
              style:
                  FontStyles.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                if (client.email.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        client.email,
                        style: FontStyles.poppins(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        tooltip: 'Copy Email',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: client.email));
                        },
                      ),
                    ],
                  ),
                if (client.contactNumber.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      client.contactNumber,
                      style: FontStyles.poppins(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'Copy Number',
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: client.contactNumber));
                      },
                    ),
                  ],
                ),
              ],
            ),
            if(client.city.isNotEmpty)
            Text(
              "City: ${client.city}",
              style: FontStyles.poppins(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if(client.state.isNotEmpty)
            Text(
              "State: ${client.state}",
              style: FontStyles.poppins(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(client.contactNumber.isNotEmpty)
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.call,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  label: const Text("Call"),
                  onPressed: () => _makeCall(client.contactNumber),
                ),
                if(client.email.isNotEmpty)
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.email,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  label: const Text("Email"),
                  onPressed: () => _sendEmail(client.email),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
