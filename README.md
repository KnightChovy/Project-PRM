# SmartStay-AI 🏨

Ứng dụng đặt phòng khách sạn (Flutter) có tích hợp **trợ lý AI** gợi ý chỗ ở phù hợp.
Người dùng có thể tìm khách sạn, xem phòng, đặt phòng, quản lý đơn và trò chuyện với AI.

> App này là **client thuần** — chỉ gọi REST API của backend, không tự xử lý
> nghiệp vụ/lưu trữ dữ liệu.

---

## 🧱 Kiến trúc: Clean Architecture

Dự án chia theo **feature-first** (mỗi tính năng là một "đảo" độc lập), bên trong
mỗi feature chia làm 3 tầng. Quy tắc quan trọng nhất: **phụ thuộc luôn hướng vào
trong** — `Presentation → Domain ← Data`.

| Tầng             | Biết Flutter? | Biết JSON/API? | Chứa logic nghiệp vụ? | Nhiệm vụ                              |
| ---------------- | :-----------: | :------------: | :-------------------: | ------------------------------------- |
| **Presentation** |      ✅       |       ❌       |          ❌           | Vẽ UI, nhận thao tác (Provider + Widget) |
| **Domain**       |      ❌       |       ❌       |          ✅           | Trung tâm: Entity, UseCase, Interface |
| **Data**         |      ❌       |       ✅       |          ❌           | Gọi API, map JSON, hiện thực Repo      |

### Luồng dữ liệu (1 chiều, dễ nhớ)

```
UI (Page)
  → gọi method → Notifier (ChangeNotifier)
    → gọi → UseCase
      → gọi → Repository (interface, ở Domain)
        ← được hiện thực bởi → RepositoryImpl (Data)
          → gọi → RemoteDataSource → API (dio)
  ← Notifier cập nhật status + notifyListeners() → UI vẽ lại
```

Lỗi đi ngược lên dưới dạng `Either<Failure, T>` (dùng `fpdart`), xử lý bằng `.fold()`
— **không** ném Exception xuyên qua các tầng.

---

## 📁 Cấu trúc thư mục

```
lib/
├── core/                      # Dùng chung toàn app, không thuộc feature nào
│   ├── constants/             # Hằng số: URL API, endpoint...
│   ├── di/                    # injection.dart — khai báo phụ thuộc (get_it)
│   ├── error/                 # failures.dart (lỗi sạch) + exceptions.dart (lỗi tầng Data)
│   ├── network/               # dio_client.dart — bọc Dio gọi HTTP tập trung
│   ├── router/                # (sẽ dùng) điều hướng go_router
│   ├── theme/                 # app_theme.dart — màu sắc & giao diện chung
│   ├── usecase/               # usecase.dart — khuôn chung cho mọi use case
│   └── utils/                 # tiện ích chung
│
├── features/
│   ├── auth/                  # ✅ Tính năng đăng nhập/đăng ký (đã làm mẫu đầy đủ)
│   │   ├── domain/            # Thuần Dart — KHÔNG import Flutter/JSON
│   │   │   ├── entities/        →  user.dart
│   │   │   ├── repositories/    →  auth_repository.dart (interface)
│   │   │   └── usecases/        →  login_user.dart, register_user.dart
│   │   ├── data/             # Biết JSON/API
│   │   │   ├── models/          →  user_model.dart (map JSON ↔ entity)
│   │   │   ├── datasources/     →  auth_remote_data_source.dart (gọi API)
│   │   │   └── repositories/    →  auth_repository_impl.dart (Exception → Failure)
│   │   └── presentation/     # Flutter
│   │       ├── providers/      →  auth_notifier.dart (ChangeNotifier)
│   │       ├── pages/          →  login/register/info_screen.dart
│   │       └── widgets/
│   │
│   ├── onboarding/            # Màn splash + giới thiệu (chỉ UI)
│   ├── hotel/                 # (khung sẵn) tìm/xem khách sạn
│   ├── booking/              # (khung sẵn) đặt & quản lý đơn
│   └── assistant/            # (khung sẵn) trợ lý AI
│
└── main.dart                  # Điểm khởi chạy: init DI rồi runApp()
```

> Mỗi feature chưa có code chứa file `.gitkeep` chỉ để giữ thư mục — khi thêm code
> thật thì xóa file đó đi.

---

## ⚙️ Cài đặt & chạy

### Yêu cầu

- Flutter SDK (Dart `^3.11.5`) — kiểm tra bằng `flutter --version`
- Một thiết bị/emulator (Android, iOS) hoặc Chrome (web)

### Các bước

```bash
# 1. Tải các package
flutter pub get

# 2. Kiểm tra môi trường (tùy chọn)
flutter doctor

# 3. Chạy app
flutter run

# Kiểm tra code có lỗi/cảnh báo không
flutter analyze
```

> ⚠️ `core/constants/api_constants.dart` đang để **URL giả**. Đổi `baseUrl` sang
> địa chỉ backend thật thì các tính năng gọi API (đăng nhập...) mới chạy được.

---

## 📦 Thư viện chính

| Mục đích             | Package        |
| -------------------- | -------------- |
| Quản lý trạng thái   | `provider` (`ChangeNotifier`) |
| Xử lý lỗi (`Either`) | `fpdart`       |
| So sánh giá trị      | `equatable`    |
| Tiêm phụ thuộc (DI)  | `get_it`       |
| Gọi HTTP             | `dio`          |

---

## 🚀 Thêm một feature mới như thế nào?

Làm theo đúng mẫu của feature `auth`, theo thứ tự từ trong ra ngoài:

1. **Domain**: tạo `entity` → `repository` (interface) → `usecase`.
2. **Data**: tạo `model` (fromJson/toJson) → `datasource` → `repository_impl`.
3. **Presentation**: tạo `notifier` (ChangeNotifier) → `page`.
4. **DI**: đăng ký trong `core/di/injection.dart` theo thứ tự
   DataSource → Repository → UseCase → Notifier.

### Vài quy tắc vàng cần nhớ

- ✅ Domain chỉ là Dart thuần — **không** import `flutter`, `dio`, JSON.
- ✅ Notifier gọi **UseCase**, không gọi thẳng Repository hay API.
- ✅ Map JSON chỉ làm trong `Model` (tầng Data).
- ✅ Trả `Either<Failure, T>` giữa các tầng; Widget không chứa logic.
- ❌ Không import chéo `data/` hay `presentation/` của feature khác — chỉ tái dùng
  qua `domain/` hoặc `core/`.
```
