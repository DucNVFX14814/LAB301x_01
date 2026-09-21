-- =====================================================================
-- Dự án: LAB301x - Dò vé số
-- Học viên: DucNVFX14814 - Nguyễn Việt Đức
-- File: schema.sql
-- Mục đích: Tạo cấu trúc CSDL và nhập dữ liệu mẫu
-- =====================================================================

DROP DATABASE IF EXISTS doveso_db;

CREATE DATABASE doveso_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE doveso_db;

-- ---------------------------------------------------------------------
-- 1. Bảng users: lưu tài khoản user
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    full_name           VARCHAR(150)  NOT NULL,
    email               VARCHAR(150)  NOT NULL UNIQUE,
    phone               VARCHAR(15)   NOT NULL UNIQUE,
    password_hash       VARCHAR(255)  NOT NULL,     -- BCrypt hash
    role                ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
    active              BOOLEAN       NOT NULL DEFAULT TRUE,
    reset_token         VARCHAR(100)  NULL,
    reset_token_expire  DATETIME      NULL,
    last_login_at       DATETIME      NULL,
    created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=1000000000;

-- ---------------------------------------------------------------------
-- 2. Bảng lottery_tickets: bảng header chứa thông tin vé dò
-- ---------------------------------------------------------------------
CREATE TABLE lottery_tickets (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    draw_date       DATE          NOT NULL UNIQUE,
    status          ENUM('UNPUBLISH','PUBLISH') NOT NULL DEFAULT 'UNPUBLISH',
    created_by      INT           NOT NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ticket_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB AUTO_INCREMENT=3000000000;

-- ---------------------------------------------------------------------
-- 3. Bảng lottery_prizes: bảng item chứa toàn bộ các giải
-- ---------------------------------------------------------------------
CREATE TABLE lottery_prizes (
    id           BIGINT       AUTO_INCREMENT PRIMARY KEY,
    ticket_id    BIGINT       NOT NULL,
    prize_code   VARCHAR(10)  NOT NULL,   -- 'DB','G1'..'G7'
    prize_name   VARCHAR(30)  NOT NULL,   -- 'Đặc biệt','Giải nhất'...
    prize_number VARCHAR(100) NOT NULL,   -- vd '10449-17020-70611'
    UNIQUE KEY uk_ticket_prize (ticket_id, prize_code),
    CONSTRAINT fk_prize_ticket FOREIGN KEY (ticket_id)
        REFERENCES lottery_tickets(id) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5000000000;

-- ---------------------------------------------------------------------
-- 4. Bảng lottery_history: lịch sử dò vé
-- ---------------------------------------------------------------------
CREATE TABLE lottery_history (
    id              BIGINT       AUTO_INCREMENT PRIMARY KEY,
    user_id         INT          NULL,
    ticket_id       BIGINT       NOT NULL,
    ticket_number   VARCHAR(10)  NOT NULL,
    result_summary  VARCHAR(255) NOT NULL,
    prize_amount    BIGINT       NULL,
    checked_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_history_ticket FOREIGN KEY (ticket_id) REFERENCES lottery_tickets(id)
) ENGINE=InnoDB AUTO_INCREMENT=7000000000;

-- =====================================================================
-- DỮ LIỆU MẪU
-- Mật khẩu cho tất cả tài khoản mẫu: 123456 (đã băm BCrypt)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. users
-- ---------------------------------------------------------------------
INSERT INTO users (full_name, email, phone, password_hash, role, active, last_login_at, created_at) VALUES
('Admin', 'admin@doveso.vn', '0900000000', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'ADMIN', TRUE, '2026-09-15 08:00:00', '2026-01-05 09:00:00'),
('Nguyễn Việt Đức', 'duc.nguyen@gmail.com', '0912345678', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-13 21:05:00', '2026-01-12 14:30:00'),
('Inactive User', 'inactive@gmail.com', '0901234567', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', FALSE, '2026-09-14 19:20:00', '2026-01-10 10:15:00'),
('Phạm Thị Thu Hà', 'ha.pham@gmail.com', '0923456789', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-10 07:45:00', '2026-01-15 08:20:00'),
('Hoàng Minh Tuấn', 'tuan.hoang@gmail.com', '0934567890', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-15 06:30:00', '2026-01-20 11:00:00'),
('Võ Thị Kim Anh', 'anh.vo@gmail.com', '0945678901', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-08-30 18:10:00', '2026-02-01 09:45:00'),
('Đặng Văn Phúc', 'phuc.dang@gmail.com', '0956789012', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-11 20:00:00', '2026-02-05 13:10:00'),
('Bùi Thị Ngọc Mai', 'mai.bui@gmail.com', '0967890123', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-09 17:25:00', '2026-02-08 15:40:00'),
('Đinh Công Danh', 'danh.dinh@gmail.com', '0934455667', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-05 08:50:00', '2026-03-20 09:10:00'),
('Trần Văn Nam', 'nam.tran@gmail.com', '0912345699', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-01 08:30:00', '2026-01-10 10:15:00'),
('Nguyễn Thị Mai', 'mai.nguyen@gmail.com', '0987654321', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-02 14:15:00', '2026-01-12 11:20:00'),
('Lê Hoàng Long', 'long.le@gmail.com', '0905123456', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-03 19:45:00', '2026-01-18 16:35:00'),
('Phạm Minh Đức', 'duc.pham@gmail.com', '0938112233', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-04 11:00:00', '2026-02-02 09:00:00'),
('Vũ Thùy Linh', 'linh.vu@gmail.com', '0977889900', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-06 15:20:00', '2026-02-14 14:50:00'),
('Đỗ Anh Tuấn', 'tuan.do@gmail.com', '0966554433', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-07 09:10:00', '2026-02-28 10:05:00'),
('Ngô Bảo Châu', 'chau.ngo@gmail.com', '0911223344', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-08 22:30:00', '2026-03-05 17:40:00'),
('Lý Hải Đăng', 'dang.ly@gmail.com', '0944332211', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-10 13:40:00', '2026-03-12 11:15:00'),
('Dương Hồng Nhung', 'nhung.duong@gmail.com', '0922446688', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-11 16:55:00', '2026-03-25 08:25:00'),
('Phan Thanh Tùng', 'tung.phan@gmail.com', '0955667788', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-12 21:05:00', '2026-04-02 13:50:00'),
('Hồ Quốc Bảo', 'bao.ho@gmail.com', '0919887766', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-14 07:15:00', '2026-04-10 10:30:00'),
('Trịnh Thu Thủy', 'thuy.trinh@gmail.com', '0988223344', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-15 10:25:00', '2026-04-15 15:10:00'),
('Mai Xuân Trường', 'truong.mai@gmail.com', '0933778899', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-16 18:50:00', '2026-04-22 16:45:00'),
('Tạ Minh Quang', 'quang.ta@gmail.com', '0944889900', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-17 12:00:00', '2026-05-01 09:20:00'),
('Đoàn Thị Diễm My', 'my.doan@gmail.com', '0971223344', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-18 14:10:00', '2026-05-12 11:00:00'),
('Nguyễn Thị Yến Nhi', 'nhi.nguyen@gmail.com', '0945566778', '$2a$12$SX7qSUIE.oMCgeQFV0eIven3rgPK94KqpK3mrtbWo6K9jJEhMr5oe', 'USER', TRUE, '2026-09-13 16:35:00', '2026-04-01 11:25:00');

-- ---------------------------------------------------------------------
-- 2. lottery_tickets
-- created_by = 1000000000 (Admin)
-- ---------------------------------------------------------------------
INSERT INTO lottery_tickets (draw_date, status, created_by, created_at) VALUES
('2026-09-18', 'PUBLISH', 1000000000, '2026-09-01 18:30:00'),
('2026-09-19', 'UNPUBLISH', 1000000000, '2026-09-01 18:30:00');

-- ---------------------------------------------------------------------
-- 3. lottery_prizes
-- ticket_id = 3000000000 / 3000000001 (2 ticket vừa insert ở trên)
-- ---------------------------------------------------------------------
INSERT INTO lottery_prizes (ticket_id, prize_code, prize_name, prize_number) VALUES
(3000000000, 'DB', 'Đặc biệt', '71960'),
(3000000000, 'G1', 'Giải nhất', '88951'),
(3000000000, 'G2', 'Giải nhì', '15911-12438'),
(3000000000, 'G3', 'Giải ba', '10449-17020-70611-78409-04537-92785'),
(3000000000, 'G4', 'Giải tư', '9977-5957-2580-2082'),
(3000000000, 'G5', 'Giải năm', '7200-3643-5164-0039-5838-3326'),
(3000000000, 'G6', 'Giải sáu', '548-075-934'),
(3000000000, 'G7', 'Giải bảy', '66-92-36-12'),
(3000000001, 'DB', 'Đặc biệt', '12345'),
(3000000001, 'G1', 'Giải nhất', '78901'),
(3000000001, 'G2', 'Giải nhì', '23456'),
(3000000001, 'G3', 'Giải ba', '34567-45678'),
(3000000001, 'G4', 'Giải tư', '01234-12345-23456-34567-45678-56789-67890'),
(3000000001, 'G5', 'Giải năm', '78901'),
(3000000001, 'G6', 'Giải sáu', '89012-90123-01234'),
(3000000001, 'G7', 'Giải bảy', '12-34-56-78');

-- ---------------------------------------------------------------------
-- 4. lottery_history (3 dòng)
-- user_id = 1000000001 (Nguyễn Việt Đức)
-- ticket_id = 3000000000 (ticket vé số ngày 2026-09-18)
-- ---------------------------------------------------------------------
INSERT INTO lottery_history (user_id, ticket_id, ticket_number, result_summary, prize_amount, checked_at) VALUES
(1000000001, 3000000000, '71960', 'Trúng Giải Đặc biệt', 1000000000, '2026-09-17 19:00:00'),
(1000000001, 3000000000, '88951', 'Trúng Giải Nhất', 15000000, '2026-09-17 19:05:00'),
(1000000001, 3000000000, '111111', 'Không trúng giải', NULL, '2026-09-17 19:10:00');

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
UPDATE users SET last_login_at = NOW() - INTERVAL 15 MINUTE WHERE email = 'duc.nguyen@gmail.com';
UPDATE users SET last_login_at = NOW() - INTERVAL 3 HOUR    WHERE email = 'ha.pham@gmail.com';
UPDATE users SET last_login_at = NOW() - INTERVAL 10 DAY    WHERE email = 'tuan.hoang@gmail.com';
UPDATE users SET last_login_at = NOW() - INTERVAL 45 DAY    WHERE email = 'anh.vo@gmail.com';
UPDATE users SET last_login_at = NOW() - INTERVAL 100 DAY   WHERE email = 'phuc.dang@gmail.com';
UPDATE users SET last_login_at = NOW() - INTERVAL 400 DAY   WHERE email = 'mai.bui@gmail.com';
UPDATE users SET last_login_at = NULL                       WHERE email = 'danh.dinh@gmail.com';

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
SELECT * FROM users;
SELECT * FROM lottery_tickets;
SELECT * FROM lottery_prizes;
SELECT * FROM lottery_history;
