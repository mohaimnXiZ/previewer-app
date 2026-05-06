import '../models/quick_link.dart';

class AppConstants {
  static const String arModelUrl =
      'https://cdn.pixabay.com/download/objects3d/2025/12/22/processed_3332__8a1756a876.glb?filename=pixellabs-robot-3332.glb';

  static const List<QuickLink> quickLinks = [
    QuickLink(
      label: 'YouTube',
      title: 'YouTube',
      url: 'https://www.youtube.com',
    ),
    QuickLink(
      label: 'Wikipedia',
      title: 'Wikipedia',
      url: 'https://www.wikipedia.org',
    ),
    QuickLink(
      label: 'Instagram',
      title: 'Instagram',
      url: 'https://www.instagram.com',
    ),
    QuickLink(
      label: 'Facebook',
      title: 'Facebook',
      url: 'https://www.facebook.com',
    ),
    QuickLink(
      label: 'Google',
      title: 'Google Chrome',
      url: 'https://www.google.com',
    ),
    QuickLink(
      label: 'apple',
      title: 'Apple legal',
      url: 'https://www.apple.com/legal/internet-services/terms/site.html',
    ),
    QuickLink(
      label: 'Shopify',
      title: 'Shopify',
      url: 'https://changelog.shopify.com/',
    ),
    QuickLink(
      label: 'Payment Example',
      title: 'Payment example',
      url: 'https://buy.stripe.com/test_3cIaEQ3MQfne2Ct6qj4sE00',
    ),
  ];
}
