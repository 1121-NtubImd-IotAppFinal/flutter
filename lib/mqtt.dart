import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

Future<MqttServerClient> createMqttClient(String cid) async {
  MqttServerClient client = MqttServerClient.withPort('140.131.115.152', cid, 1883);

  // Set up event handlers
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  // Connect to the broker
  final connMessage = MqttConnectMessage()
      .withClientIdentifier(cid)
      .authenticateAs('', '')
      .startClean() // Start with a clean session
      .withWillQos(MqttQos.atLeastOnce)
      .withWillRetain()
      .authenticateAs('wow0422796353', '123456');
  client.connectionMessage = connMessage;

  try {
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  return client;
}

void onConnected() {
  print('Connected');
}

void onDisconnected() {
  print('Disconnected');
}

void onSubscribed(String topic) {
  print('Subscribed to topic: $topic');
}

void onSubscribeFail(String topic) {
  print('Failed to subscribe to topic: $topic');
}

void pong() {
  print('Ping response');
}

Future<void> sendMessage(MqttServerClient client, String topic, String message) async {
  final builder = MqttClientPayloadBuilder();
  builder.addString(message);

  client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
}

void subscribeToTopic(MqttServerClient client, String topic) {
  client.subscribe(topic, MqttQos.atMostOnce);
}

void listenToIncomingMessages(MqttServerClient client, String topic) {
  client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> event) {
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('Received message on topic $topic: $message');
  });
}

// void main() async {
  

//   // Example of sending a message
  

//   // Example of subscribing to a topic
//   subscribeToTopic(client, 'topic');

//   // Example of listening for incoming messages on a topic
//   listenToIncomingMessages(client, 'topic');
// }
