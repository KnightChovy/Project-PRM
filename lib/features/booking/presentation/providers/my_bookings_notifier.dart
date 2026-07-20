import 'package:flutter/foundation.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/usecases/get_my_bookings.dart';
import 'booking_notifier.dart' show RequestStatus;

/// Danh sách booking của tôi, có lọc theo trạng thái và tải thêm trang.
class MyBookingsNotifier extends ChangeNotifier {
  final GetMyBookings getMyBookings;

  MyBookingsNotifier(this.getMyBookings);

  static const int pageSize = 20;

  RequestStatus status = RequestStatus.initial;
  List<Booking> bookings = const [];
  BookingStatus? filter;
  String? errorMessage;

  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  bool get isLoading => status == RequestStatus.loading;
  bool get hasMore => _page < _totalPages;
  bool get isEmpty => status == RequestStatus.success && bookings.isEmpty;

  // ---- Nhóm cho 3 tab của màn My Bookings ----
  // API chỉ lọc được MỘT `status` mỗi lần, mà tab "Upcoming" gộp 3 trạng thái,
  // nên tải hết rồi nhóm ở client thay vì gọi 3 request.

  List<Booking> get upcoming => _where(const {
        BookingStatus.pending,
        BookingStatus.confirmed,
        BookingStatus.checkedIn,
      });

  List<Booking> get completed => _where(const {BookingStatus.checkedOut});

  List<Booking> get cancelled => _where(const {
        BookingStatus.cancelled,
        BookingStatus.noShow,
      });

  List<Booking> _where(Set<BookingStatus> statuses) =>
      bookings.where((b) => statuses.contains(b.status)).toList(growable: false);

  /// Tải lại từ trang 1. Gọi khi mở màn hoặc khi user đổi tab trạng thái.
  Future<void> load({BookingStatus? filterBy}) async {
    filter = filterBy;
    status = RequestStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await getMyBookings(
      GetMyBookingsParams(status: filter, page: 1, limit: pageSize),
    );
    result.fold(
      (failure) {
        status = RequestStatus.error;
        errorMessage = failure.message;
      },
      (paged) {
        status = RequestStatus.success;
        bookings = paged.items;
        _page = paged.page;
        _totalPages = paged.totalPages;
      },
    );
    notifyListeners();
  }

  /// Tải trang kế tiếp và nối vào danh sách hiện có.
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;

    final result = await getMyBookings(
      GetMyBookingsParams(status: filter, page: _page + 1, limit: pageSize),
    );
    result.fold(
      (failure) {
        errorMessage = failure.message;
      },
      (paged) {
        bookings = [...bookings, ...paged.items];
        _page = paged.page;
        _totalPages = paged.totalPages;
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }
}
