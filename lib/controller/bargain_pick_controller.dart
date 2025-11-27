import 'package:zatch_app/model/bargain_pick_model.dart';

class BargainPickController {final List<BargainPick> picks = [
  BargainPick(
    id: '68a2772c675bafdd4204ef0b',
    title: 'Modern Clothes',
    subtitle: 'Zatch from less than 150',
    videoAsset: 'assets/videos/vid1.mp4',
    productTitle: 'Modern light clothes',
    productPrice: '212.99 ₹',
    // --- MODIFIED ---
    thumbnail: 'https://images.pexels.com/photos/1055691/pexels-photo-1055691.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  BargainPick(
    id: '68e7ef890af7d224a57aa9a2',
    title: 'Trendy Jackets',
    subtitle: 'Zatch winter fits',
    videoAsset: 'assets/videos/vid2.mp4',
    productTitle: 'Winter Jacket',
    productPrice: '499.99 ₹',
    // --- MODIFIED ---
    thumbnail: 'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  BargainPick(
    id: '68e7f2900af7d224a57aa9ac',
    title: 'Streetwear',
    subtitle: 'Zatch budget tees',
    videoAsset: 'assets/videos/vid3.mp4',
    productTitle: 'Casual Streetwear Tee',
    productPrice: '199.99 ₹',
    // --- MODIFIED ---
    thumbnail: 'https://images.pexels.com/photos/2584269/pexels-photo-2584269.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  BargainPick(
    id: '68e7f2560af7d224a57aa9a9',
    title: 'Accessories',
    subtitle: 'Zatch from 99 only',
    videoAsset: 'assets/videos/vid4.mp4',
    productTitle: 'Stylish Watch',
    productPrice: '99.99 ₹',
    // --- MODIFIED ---
    thumbnail: 'https://images.pexels.com/photos/277390/pexels-photo-277390.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
];

void addPick(BargainPick pick) {
  picks.add(pick);
}
}
