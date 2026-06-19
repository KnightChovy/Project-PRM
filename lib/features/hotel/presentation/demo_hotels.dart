import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';

/// Dữ liệu khách sạn mẫu dùng chung cho Home / Search / Map View.
///
/// NOTE: khi có backend, thay bằng UseCase `SearchHotels` + Notifier lấy từ API.
/// Tạm để ở tầng presentation (giống `_demoRooms` trong RoomListPage) vì chưa
/// có nguồn dữ liệu thật.
const List<Hotel> kDemoHotels = [
  Hotel(
    id: 'h1',
    name: 'Amanoi Resort',
    location: 'Vinh Hy Bay, Ninh Thuan, Vietnam',
    imageUrl:
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
    rating: 4.9,
    reviewCount: 1284,
    pricePerNight: 850,
    description:
        'Choosing a spectacular stretch of Vietnam\'s coastline within the lush '
        'embrace of Nui Chua National Park, Amanoi is a secluded, luxury retreat. '
        'The resort offers all-suite infinity pools, a serene lakeside Aman Spa, '
        'and unparalleled privacy.',
    amenities: ['WiFi', 'Pool', 'Spa', 'Gym', 'Restaurant', 'Private Beach'],
    images: [
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
    ],
  ),
  Hotel(
    id: 'h2',
    name: 'InterContinental',
    location: 'Da Nang, Vietnam',
    imageUrl:
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
    rating: 4.8,
    reviewCount: 932,
    pricePerNight: 550,
    oldPrice: 620,
    description:
        'A multi-tiered hillside resort nestled on the Son Tra Peninsula, blending '
        'contemporary luxury with traditional Vietnamese design. Private beach, '
        'award-winning dining and a world-class spa.',
    amenities: ['WiFi', 'Pool', 'Spa', 'Gym', 'Restaurant', 'Private Beach'],
    images: [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
    ],
  ),
  Hotel(
    id: 'h3',
    name: 'JW Marriott Resort',
    location: 'Phu Quoc, Vietnam',
    imageUrl:
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
    rating: 4.7,
    reviewCount: 1043,
    pricePerNight: 480,
    description:
        'Set on the secluded Khem Beach, this whimsical resort is themed around a '
        'fictional university. Expansive pools, fine dining and a tranquil spa make '
        'it a perfect escape.',
    amenities: ['WiFi', 'Pool', 'Spa', 'Restaurant', 'Private Beach'],
    images: [
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
    ],
  ),
  Hotel(
    id: 'h4',
    name: 'The Regent',
    location: 'Long Beach, Phu Quoc, Vietnam',
    imageUrl:
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
    rating: 4.6,
    reviewCount: 718,
    pricePerNight: 458,
    description:
        'An all-suite-and-villa beachfront resort facing the sunset coast of Phu '
        'Quoc. Refined interiors, three signature restaurants and a serene spa.',
    amenities: ['WiFi', 'Pool', 'Spa', 'Gym', 'Restaurant'],
    images: [
      'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
      'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800',
    ],
  ),
  Hotel(
    id: 'h5',
    name: 'Six Senses Ninh Van Bay',
    location: 'Nha Trang, Vietnam',
    imageUrl:
        'https://images.unsplash.com/photo-1568084680786-a84f91d1153c?w=800',
    rating: 4.9,
    reviewCount: 654,
    pricePerNight: 720,
    description:
        'Reached only by boat, this hideaway scatters rustic-chic pool villas across '
        'a pristine bay framed by dramatic rock formations.',
    amenities: ['WiFi', 'Pool', 'Spa', 'Restaurant', 'Private Beach'],
    images: [
      'https://images.unsplash.com/photo-1568084680786-a84f91d1153c?w=800',
      'https://images.unsplash.com/photo-1582610116397-edb318620f90?w=800',
    ],
  ),
  Hotel(
    id: 'h6',
    name: 'Capella Hanoi',
    location: 'Hoan Kiem, Hanoi, Vietnam',
    imageUrl:
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
    rating: 4.7,
    reviewCount: 489,
    pricePerNight: 390,
    oldPrice: 430,
    description:
        'A theatrical, opera-inspired urban retreat steps from the Hanoi Opera House, '
        'pairing 1920s glamour with intimate, art-filled suites.',
    amenities: ['WiFi', 'Spa', 'Gym', 'Restaurant'],
    images: [
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
    ],
  ),
];

/// Các điểm đến phổ biến (Popular Destinations) hiện ở Home.
class Destination {
  final String name;
  final String imageUrl;
  const Destination(this.name, this.imageUrl);
}

const List<Destination> kPopularDestinations = [
  Destination(
      'Bali', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400'),
  Destination(
      'Da Nang', 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=400'),
  Destination(
      'Ha Long', 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400'),
  Destination(
      'Tokyo', 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400'),
  Destination(
      'Phu Quoc', 'https://images.unsplash.com/photo-1583394293214-28a5b42e4f4c?w=400'),
];
