import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/core/widgets/app_network_image.dart';
import 'package:smart_stay_ai/features/review/domain/entities/review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/upload_review_image.dart';
import 'package:smart_stay_ai/features/review/presentation/providers/review_notifier.dart';

/// Một ảnh khách vừa chọn — giữ bytes (hiện thumbnail + upload đa nền tảng).
class _PickedPhoto {
  final Uint8List bytes;
  final String name;
  const _PickedPhoto(this.bytes, this.name);
}

/// Tham số truyền vào màn Write Review (qua `extra` của go_router).
class WriteReviewArgs {
  /// Id booking đã trả phòng cần đánh giá (bắt buộc cho API POST /reviews).
  final String bookingId;
  final String hotelName;
  final String location;
  final String imageUrl;
  const WriteReviewArgs({
    required this.bookingId,
    required this.hotelName,
    required this.location,
    this.imageUrl = '',
  });
}

/// Màn "Write Review" — khách chấm sao + viết nhận xét cho một chỗ đã ở.
class WriteReviewPage extends StatefulWidget {
  const WriteReviewPage({super.key, required this.args});
  final WriteReviewArgs args;

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  // --- State của form (UI state, được phép giữ trong widget) ---
  int _overall = 0;
  int _cleanliness = 0;
  int _locationRating = 0;
  int _service = 0;
  int _value = 0;
  bool _anonymous = false;
  final _commentCtrl = TextEditingController();

  // Ảnh đính kèm (tối đa 5). Server cho tối đa 10, nhưng UI gọn 5 là đủ.
  static const _maxPhotos = 5;
  final ImagePicker _picker = ImagePicker();
  final List<_PickedPhoto> _photos = [];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() => _photos.add(_PickedPhoto(bytes, x.name)));
  }

  Future<void> _onSubmit(ReviewNotifier notifier) async {
    final ok = await notifier.submit(
      SubmitReviewParams(
        bookingId: widget.args.bookingId,
        overall: _overall,
        cleanliness: _cleanliness,
        locationRating: _locationRating,
        service: _service,
        value: _value,
        comment: _commentCtrl.text.trim(),
      ),
      photos: _photos
          .map((p) => UploadReviewImageParams(bytes: p.bytes, filename: p.name))
          .toList(),
    );
    if (!mounted) return;
    // Side effect (snackbar/điều hướng) đặt ở widget, sau khi await xong.
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
      );
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(notifier.errorMessage ?? 'Có lỗi xảy ra')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          sl<ReviewNotifier>()..checkExisting(widget.args.bookingId),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Write Review',
            style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Consumer<ReviewNotifier>(
            builder: (context, notifier, _) {
              final existing = notifier.existing;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _hotelHeader(),
                  const SizedBox(height: 20),
                  // Đã đánh giá rồi → chỉ-đọc; chưa thì hiện form.
                  if (existing != null) ..._readOnly(existing),
                  if (existing == null) ..._form(notifier),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Form chấm điểm (khi CHƯA từng đánh giá chỗ này).
  List<Widget> _form(ReviewNotifier notifier) {
    return [
      const Center(
        child: Text('OVERALL RATING',
            style: TextStyle(letterSpacing: 1, color: AppColors.textSecondary)),
      ),
      const SizedBox(height: 8),
      Center(
        child: _StarRow(
          value: _overall,
          size: 40,
          onChanged: (v) => setState(() => _overall = v),
        ),
      ),
      const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Tap to rate',
              style: TextStyle(color: AppColors.hint, fontSize: 12)),
        ),
      ),
      const SizedBox(height: 20),
      _criteria('Cleanliness', _cleanliness,
          (v) => setState(() => _cleanliness = v)),
      _criteria('Location', _locationRating,
          (v) => setState(() => _locationRating = v)),
      _criteria('Service', _service, (v) => setState(() => _service = v)),
      _criteria('Value', _value, (v) => setState(() => _value = v)),
      const SizedBox(height: 16),
      _inspirationCard(),
      const SizedBox(height: 16),
      _commentField(),
      const SizedBox(height: 16),
      _addPhotos(),
      const SizedBox(height: 16),
      _anonymousToggle(),
      const SizedBox(height: 24),
      _submitButton(notifier),
    ];
  }

  /// Hiển thị lại đánh giá đã gửi (không cho sửa/gửi lại).
  List<Widget> _readOnly(Review review) {
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.verified_outlined, color: Color(0xFF3B7A57), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text('Bạn đã đánh giá chỗ này. Dưới đây là nội dung đã gửi.',
                  style: TextStyle(color: Color(0xFF3B7A57))),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const Center(
        child: Text('OVERALL RATING',
            style: TextStyle(letterSpacing: 1, color: AppColors.textSecondary)),
      ),
      const SizedBox(height: 8),
      Center(child: _StarRow(value: review.overall, size: 40, readOnly: true)),
      const SizedBox(height: 20),
      _criteriaStatic('Cleanliness', review.cleanliness),
      _criteriaStatic('Location', review.locationRating),
      _criteriaStatic('Service', review.service),
      _criteriaStatic('Value', review.value),
      const SizedBox(height: 16),
      if (review.comment.isNotEmpty) ...[
        const Text('Nhận xét của bạn',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.goldLight),
          ),
          child: Text(review.comment,
              style: const TextStyle(color: AppColors.textPrimary)),
        ),
      ],
    ];
  }

  Widget _hotelHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: 48,
            height: 48,
            child: AppNetworkImage(url: widget.args.imageUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.args.hotelName,
                  style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text(widget.args.location,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _criteria(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          _StarRow(value: value, size: 22, onChanged: onChanged),
        ],
      ),
    );
  }

  /// Một dòng tiêu chí ở chế độ chỉ-đọc (không bấm được).
  Widget _criteriaStatic(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          _StarRow(value: value, size: 22, readOnly: true),
        ],
      ),
    );
  }

  /// Khu "Add Photos" — chọn ảnh thật từ thư viện, upload khi bấm Submit.
  Widget _addPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Photos',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (var i = 0; i < _photos.length; i++) _photoThumb(i),
            if (_photos.length < _maxPhotos) _addSlot(),
          ],
        ),
      ],
    );
  }

  Widget _photoThumb(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _photos[index].bytes,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(index)),
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.goldDark,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addSlot() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.goldLight, width: 1.5),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.gold),
      ),
    );
  }

  Widget _inspirationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Need inspiration? Gợi ý một bản nháp đánh giá dựa trên kỳ nghỉ của bạn.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentField() {
    return TextField(
      controller: _commentCtrl,
      maxLines: 5,
      maxLength: 500,
      decoration: InputDecoration(
        hintText: 'Chia sẻ trải nghiệm của bạn...',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.goldLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.goldLight),
        ),
      ),
    );
  }

  Widget _anonymousToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Đăng ẩn danh',
            style: TextStyle(color: AppColors.textPrimary)),
        Switch(
          value: _anonymous,
          activeThumbColor: AppColors.gold,
          onChanged: (v) => setState(() => _anonymous = v),
        ),
      ],
    );
  }

  Widget _submitButton(ReviewNotifier notifier) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: notifier.isSubmitting ? null : () => _onSubmit(notifier),
        child: notifier.isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Submit Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Hàng 5 ngôi sao có thể bấm để chấm điểm.
class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.value,
    this.onChanged,
    this.size = 24,
    this.readOnly = false,
  });

  final int value;
  final double size;
  final ValueChanged<int>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: readOnly ? null : () => onChanged?.call(i + 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: filled ? AppColors.gold : AppColors.hint,
          ),
        );
      }),
    );
  }
}
