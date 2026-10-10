# Dò Vé Số

Website tra cứu và quản lý dò vé số kiến thiết - Đồ án môn LAB301x.

Học viên: **DucNVFX14814 - Nguyễn Việt Đức**

## 1. Công nghệ sử dụng

|---------------------------|-----------------------------------------------------------|
| Thành phần                | Công nghệ                                                 |
|---------------------------|-----------------------------------------------------------|
| Frontend (public)         | Bootstrap 5                                               |
| Frontend (trang quản trị) | SB Admin 2 (Bootstrap, mã nguồn mở)                       |
| View                      | JSP + JSTL                                                |
| Backend                   | Java Servlet (Jakarta/Java EE, chạy trên Apache Tomcat 9) |
| Kết nối CSDL              | JDBC (mysql-connector-java) + connection pool HikariCP    |
| CSDL                      | MySQL 8.0                                                 |
| Build tool                | Apache Maven                                              |
| Mã hoá mật khẩu           | jBCrypt                                                   |
|---------------------------|-----------------------------------------------------------|

## 2. Cấu trúc thư mục

```
DoVeSo/
├── pom.xml                        # Khai báo dependency (Maven)
├── database/schema.sql            # Script tạo CSDL
├── docs/                          # Coding standard
│   ├── Java_Coding_Standard.md
│   └── HTML_JSP_Coding_Standard.md
└── src/main/
    ├── java/com/doveso/
    │   ├── model/                 # Entity: User, LotteryTicket, DrawHistory
    │   ├── bo/                    # Tầng nghiệp vụ (BO): UserBO, TicketBO, LotteryCheckBO, PasswordResetBO, NumberSuggestionBO, UserHistoryBO
    │   ├── dao/, dao/impl/        # Tầng truy xuất dữ liệu (JDBC)
    │   ├── controller/            # Servlet, chia theo tính năng
    │   │   ├── auth/              # Đăng ký, đăng nhập, đăng xuất
    │   │   ├── admin/             # Quản lý người dùng, quản lý vé dò
    │   │   ├── user/              # Đổi mật khẩu, lịch sử dò vé, đề xuất số
    │   │   └── lottery/           # Dò vé số
    │   ├── filter/                # Filter xác thực, phân quyền, encoding
    │   ├── util/                  # DBConnectionUtil (connection pool), PasswordUtil, ValidationUtil, ...
    │   └── listener/              # DbPoolListener: đóng connection pool khi ứng dụng dừng
    ├── resources/db.properties    # Cấu hình kết nối CSDL + connection pool (db.pool.*)
    ├── resources/mail.properties.example  # File mẫu cấu hình gửi email (xem mục 3, bước 4)
    └── webapp/
        ├── WEB-INF/web.xml
        ├── WEB-INF/views/         # JSP files
        └── assets/                # CSS/JS/Images
```

## 3. Hướng dẫn cài đặt (môi trường phát triển)

1. Cài đặt JDK 17+, Apache Maven, Apache Tomcat 9, MySQL 8.0.
2. Tạo CSDL: chạy script `database/schema.sql` trên MySQL.
3. Mở `src/main/resources/db.properties`, sửa lại `db.username`/`db.password` theo môi trường của bạn.
4. (Tuỳ chọn - chức năng Quên mật khẩu gửi email) Copy `src/main/resources/mail.properties.example`
   thành `src/main/resources/mail.properties` rồi điền email + App Password của bạn. File
   `mail.properties` đã nằm trong `.gitignore`, **không commit/đẩy lên Git**. Có thể thay bằng biến môi trường
   `DOVESO_MAIL_USERNAME` / `DOVESO_MAIL_PASSWORD` (ưu tiên hơn file). Để trống thì hệ thống chỉ ghi log,
   không gửi email. Tương tự, `db.url` / `db.username` / `db.password` có thể ghi đè bằng biến môi trường
   `DOVESO_DB_URL` / `DOVESO_DB_USERNAME` / `DOVESO_DB_PASSWORD`.
5. Import dự án vào Eclipse/IntelliJ dưới dạng **Maven Project**.
6. Chạy `mvn clean package` để build ra file `target/doveso.war`.
7. Deploy `doveso.war` vào thư mục `webapps` của Tomcat (hoặc dùng plugin Tomcat của IDE).
8. Truy cập `http://localhost:8080/doveso/`.

> Ghi chú: dependency `mysql-connector-java` được Maven tự tải về khi build,
> không cần tải thủ công. Nếu môi trường không có Internet, tải trực tiếp tại
> https://dev.mysql.com/downloads/connector/j/ rồi thêm vào `WEB-INF/lib`.

## 4. Unit test (JUnit 5 + Mockito)

Có 2 nhóm test:

**a) Unit test logic nghiệp vụ - không cần CSDL, không cần Internet** (`src/test/java/com/doveso/bo/`
và `src/test/java/com/doveso/util/`):

- Tầng BO (mock DAO, nguồn kết quả xổ số và cổng gửi mail bằng Mockito): `UserBOImplTest`,
  `TicketBOImplTest`, `LotteryCheckBOImplTest`, `PasswordResetBOImplTest`, `NumberSuggestionBOImplTest`,
  `UserHistoryBOImplTest`.
- Hàm nghiệp vụ thuần: `LotteryCheckUtilTest` (đối chiếu trúng giải), `NumberSuggestionUtilTest` (đề xuất số),
  `ValidationUtilTest`, `PasswordUtilTest`, `ResetTokenUtilTest`, `LotteryResultCacheTest`, `ConfigUtilTest`.
- `MinhNgocClientParseTest`: kiểm tra phân tích HTML trang kết quả trên file mẫu
  `src/test/resources/minhngoc-mien-bac.html` (cắt từ trang kết quả miền Bắc thật).
- Filter (`src/test/java/com/doveso/filter/`) và model có logic hiển thị (`src/test/java/com/doveso/model/`).
- Chạy riêng nhóm này (bỏ qua test DAO cần MySQL): `mvn test -Dtest="!*DAOImplTest"`.

**b) Integration test DAO** (mô tả bên dưới) - cần MySQL đang chạy:

- Vị trí: `src/test/java/com/doveso/dao/impl/` - test cho toàn bộ 7 lớp DAO (`UserDAOImpl`,
  `CompanyDAOImpl`, `TicketDAOImpl`, `LotteryPrizeDAOImpl`, `LotteryHistoryDAOImpl`,
  `LotteryPrizeConfigDAOImpl`, `NumberStatDAOImpl`).
- Đây là **integration test**: chạy trực tiếp trên CSDL MySQL thật (đọc cấu hình từ
  `src/main/resources/db.properties`, giống lúc chạy app), không dùng mock/DB giả lập.
  Vì vậy MySQL phải đang chạy và đã có CSDL `doveso_db` (đã tạo theo mục 3) trước khi chạy test.
- Mỗi test tự tạo dữ liệu riêng (email/SĐT/mã công ty có hậu tố ngẫu nhiên, ngày quay số ở rất xa
  tương lai) và tự xoá lại trong `@AfterEach` - không đụng đến dữ liệu thật đang có trong CSDL.
- Chạy toàn bộ test: `mvn test`. Chạy trong IDE: click phải vào thư mục `src/test/java` → Run Tests,
  hoặc mở từng file `*Test.java` và bấm nút Run cạnh từng hàm test.
- Do đây là integration test cần DB thật, `mvn clean package` (build ra file .war) cũng sẽ chạy các
  test này trước khi đóng gói; nếu MySQL chưa bật, lệnh build sẽ báo lỗi. Muốn build mà bỏ qua test:
  `mvn clean package -DskipTests`.

## 5. Ghi chú tổ chức mã nguồn

- Tuân theo mô hình MVC nhiều tầng: JSP (View) → Servlet (Controller) → BO (nghiệp vụ) → DAO (truy xuất dữ liệu).
  Servlet chỉ đọc request, gọi BO rồi chuyển kết quả sang JSP; quy tắc nghiệp vụ nằm ở BO.
- Phân trang dùng phía server (SQL LIMIT/OFFSET) cho danh sách người dùng (20/trang) và vé dò (10/trang).
- Toàn bộ JSP đặt trong `WEB-INF/views` để bắt buộc đi qua Servlet, không truy cập trực tiếp.
- Quy ước đặt tên, comment: xem `docs/Java_Coding_Standard.md` và `docs/HTML_JSP_Coding_Standard.md`.
- Chi tiết kiến trúc, sơ đồ thành phần: xem tài liệu `DucNVFX14814_SRS.docx`.
