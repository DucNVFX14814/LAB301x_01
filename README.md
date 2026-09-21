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
| Kết nối CSDL              | JDBC (mysql-connector-java)                               |
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
    │   ├── dao/, dao/impl/        # Tầng truy xuất dữ liệu (JDBC)
    │   ├── controller/            # Servlet, chia theo tính năng
    │   │   ├── auth/              # Đăng ký, đăng nhập, đăng xuất
    │   │   ├── admin/             # Quản lý người dùng, quản lý vé dò
    │   │   ├── user/              # Đổi mật khẩu, lịch sử dò vé
    │   │   └── lottery/           # Dò vé số
    │   ├── filter/                # Filter xác thực, phân quyền, encoding
    │   ├── util/                  # DBConnectionUtil, PasswordUtil, ValidationUtil
    │   └── listener/
    ├── resources/db.properties    # Cấu hình kết nối CSDL
    └── webapp/
        ├── WEB-INF/web.xml
        ├── WEB-INF/views/         # JSP files
        └── assets/                # CSS/JS/Images
```

## 3. Hướng dẫn cài đặt (môi trường phát triển)

1. Cài đặt JDK 11+, Apache Maven, Apache Tomcat 9, MySQL 8.0.
2. Tạo CSDL: chạy script `database/schema.sql` trên MySQL.
3. Mở `src/main/resources/db.properties`, sửa lại `db.username`/`db.password` theo môi trường của bạn.
4. Import dự án vào Eclipse/IntelliJ dưới dạng **Maven Project**.
5. Chạy `mvn clean package` để build ra file `target/doveso.war`.
6. Deploy `doveso.war` vào thư mục `webapps` của Tomcat (hoặc dùng plugin Tomcat của IDE).
7. Truy cập `http://localhost:8080/doveso/`.

> Ghi chú: dependency `mysql-connector-java` được Maven tự tải về khi build,
> không cần tải thủ công. Nếu môi trường không có Internet, tải trực tiếp tại
> https://dev.mysql.com/downloads/connector/j/ rồi thêm vào `WEB-INF/lib`.

## 4. Ghi chú tổ chức mã nguồn

- Tuân theo mô hình MVC: JSP (View) → Servlet (Controller) → DAO (Model/Data).
- Toàn bộ JSP đặt trong `WEB-INF/views` để bắt buộc đi qua Servlet, không truy cập trực tiếp.
- Quy ước đặt tên, comment: xem `docs/Java_Coding_Standard.md` và `docs/HTML_JSP_Coding_Standard.md`.
- Chi tiết kiến trúc, sơ đồ thành phần: xem tài liệu `DucNVFX14814_SRS.docx`.
