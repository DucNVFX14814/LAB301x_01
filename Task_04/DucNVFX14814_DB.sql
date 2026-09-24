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
    phone               VARCHAR(10)   NOT NULL UNIQUE,
    password_hash       VARCHAR(255)  NOT NULL,     -- BCrypt hash
    role                ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
    active              BOOLEAN       NOT NULL DEFAULT TRUE,
    reset_token         VARCHAR(100)  NULL,
    reset_token_expire  DATETIME      NULL,
    last_login_at       DATETIME      NULL,
    created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=10000000;

-- ---------------------------------------------------------------------
-- 2. Bảng lottery_regions: danh mục miền
-- ---------------------------------------------------------------------
CREATE TABLE lottery_regions (
    region_code   VARCHAR(10)   PRIMARY KEY,    -- 'BAC','TRUNG','NAM'
    region_name   VARCHAR(50)   NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Bảng lottery_companies: danh sách công ty xổ số (đài)
-- ---------------------------------------------------------------------
CREATE TABLE lottery_companies (
    company_code  VARCHAR(30)   PRIMARY KEY,    -- vd 'mien-bac', 'tp-hcm'
    company_name  VARCHAR(50)   NOT NULL,
    region_code   VARCHAR(10)   NOT NULL,
    active        BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_company_region FOREIGN KEY (region_code) REFERENCES lottery_regions(region_code)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. Bảng lottery_prize_configs: cơ cấu giải thưởng theo miền
-- ---------------------------------------------------------------------
CREATE TABLE lottery_prize_configs (
    id            INT          AUTO_INCREMENT PRIMARY KEY,
    region_code   VARCHAR(10)  NOT NULL,
    prize_code    VARCHAR(10)  NOT NULL,   -- 'DB','G1'..'G8'
    prize_name    VARCHAR(30)  NOT NULL,   -- 'Đặc biệt','Giải nhất'...
    prize_amount  BIGINT       NOT NULL,   -- giá trị giải (VNĐ)
    UNIQUE KEY uk_config_region_prize (region_code, prize_code),
    CONSTRAINT fk_config_region FOREIGN KEY (region_code) REFERENCES lottery_regions(region_code)
) ENGINE=InnoDB AUTO_INCREMENT=90000000;

-- ---------------------------------------------------------------------
-- 5. Bảng lottery_tickets: bảng header chứa thông tin vé dò
-- ---------------------------------------------------------------------
CREATE TABLE lottery_tickets (
    id              INT           AUTO_INCREMENT PRIMARY KEY,
    company_code    VARCHAR(30)   NOT NULL,
    draw_date       DATE          NOT NULL,
    status          ENUM('UNPUBLISH','PUBLISH') NOT NULL DEFAULT 'UNPUBLISH',
    created_by      INT           NOT NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_ticket_company_date (company_code, draw_date),
    CONSTRAINT fk_ticket_company FOREIGN KEY (company_code) REFERENCES lottery_companies(company_code),
    CONSTRAINT fk_ticket_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB AUTO_INCREMENT=30000000;

-- ---------------------------------------------------------------------
-- 6. Bảng lottery_ticket_items: bảng item chứa toàn bộ các giải
-- ---------------------------------------------------------------------
CREATE TABLE lottery_ticket_items (
    id           INT          AUTO_INCREMENT PRIMARY KEY,
    ticket_id    INT          NOT NULL,
    prize_code   VARCHAR(10)  NOT NULL,   -- 'DB','G1'..'G8'
    prize_name   VARCHAR(30)  NOT NULL,   -- 'Đặc biệt','Giải nhất'...
    prize_number VARCHAR(100) NOT NULL,   -- vd '10449-17020-70611'
    UNIQUE KEY uk_ticket_prize (ticket_id, prize_code),
    CONSTRAINT fk_prize_ticket FOREIGN KEY (ticket_id)
        REFERENCES lottery_tickets(id) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50000000;

-- ---------------------------------------------------------------------
-- 7. Bảng lottery_history: lịch sử dò vé
-- ---------------------------------------------------------------------
CREATE TABLE lottery_history (
    id              INT          AUTO_INCREMENT PRIMARY KEY,
    user_id         INT          NOT NULL,
    ticket_id       INT          NOT NULL,
    ticket_number   VARCHAR(10)  NOT NULL,
    result_summary  VARCHAR(255) NOT NULL,
    prize_amount    BIGINT       NULL,
    checked_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_history_ticket FOREIGN KEY (ticket_id) REFERENCES lottery_tickets(id)
) ENGINE=InnoDB AUTO_INCREMENT=70000000;

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
-- 2. lottery_regions
-- ---------------------------------------------------------------------
INSERT INTO lottery_regions (region_code, region_name) VALUES
('BAC',   'Miền Bắc'),
('TRUNG', 'Miền Trung'),
('NAM',   'Miền Nam');

-- ---------------------------------------------------------------------
-- 3. lottery_companies (active mặc định TRUE)
-- ---------------------------------------------------------------------
INSERT INTO lottery_companies (company_code, company_name, region_code) VALUES
('mien-bac',    'Miền Bắc',     'BAC'),
('phu-yen',     'Phú Yên',      'TRUNG'),
('quang-nam',   'Quảng Nam',    'TRUNG'),
('da-nang',     'Đà Nẵng',      'TRUNG'),
('quang-tri',   'Quảng Trị',    'TRUNG'),
('ninh-thuan',  'Ninh Thuận',   'TRUNG'),
('quang-ngai',  'Quảng Ngãi',   'TRUNG'),
('khanh-hoa',   'Khánh Hòa',    'TRUNG'),
('tp-hcm',      'TP. HCM',      'NAM'),
('ben-tre',     'Bến Tre',      'NAM'),
('dong-nai',    'Đồng Nai',     'NAM'),
('tay-ninh',    'Tây Ninh',     'NAM'),
('vinh-long',   'Vĩnh Long',    'NAM'),
('long-an',     'Long An',      'NAM'),
('tien-giang',  'Tiền Giang',   'NAM');

-- ---------------------------------------------------------------------
-- 4. lottery_prize_configs
-- BAC: 8 giải (DB..G7). TRUNG/NAM: 9 giải (DB..G8), theo cơ cấu giải thưởng Minh Ngọc
-- ---------------------------------------------------------------------
INSERT INTO lottery_prize_configs (region_code, prize_code, prize_name, prize_amount) VALUES
('BAC', 'DB', 'Đặc biệt', 500000000),
('BAC', 'G1', 'Giải nhất', 10000000),
('BAC', 'G2', 'Giải nhì', 5000000),
('BAC', 'G3', 'Giải ba', 1000000),
('BAC', 'G4', 'Giải tư', 400000),
('BAC', 'G5', 'Giải năm', 200000),
('BAC', 'G6', 'Giải sáu', 100000),
('BAC', 'G7', 'Giải bảy', 40000),
('TRUNG', 'DB', 'Đặc biệt', 2000000000),
('TRUNG', 'G1', 'Giải nhất', 30000000),
('TRUNG', 'G2', 'Giải nhì', 15000000),
('TRUNG', 'G3', 'Giải ba', 10000000),
('TRUNG', 'G4', 'Giải tư', 3000000),
('TRUNG', 'G5', 'Giải năm', 1000000),
('TRUNG', 'G6', 'Giải sáu', 400000),
('TRUNG', 'G7', 'Giải bảy', 200000),
('TRUNG', 'G8', 'Giải tám', 100000),
('NAM', 'DB', 'Đặc biệt', 2000000000),
('NAM', 'G1', 'Giải nhất', 30000000),
('NAM', 'G2', 'Giải nhì', 15000000),
('NAM', 'G3', 'Giải ba', 10000000),
('NAM', 'G4', 'Giải tư', 3000000),
('NAM', 'G5', 'Giải năm', 1000000),
('NAM', 'G6', 'Giải sáu', 400000),
('NAM', 'G7', 'Giải bảy', 200000),
('NAM', 'G8', 'Giải tám', 100000);

-- ---------------------------------------------------------------------
-- 5. lottery_tickets
-- 10 kỳ quay XSMB 01/09/2026 - 10/09/2026 (nguồn: Minh Ngọc)
-- company_code = 'mien-bac', created_by = 10000000 (Admin)
-- id vé: 30000000 (01/09) ... 30000009 (10/09)
-- ---------------------------------------------------------------------
INSERT INTO lottery_tickets (company_code, draw_date, status, created_by, created_at) VALUES
('mien-bac', '2026-09-01', 'PUBLISH', 10000000, '2026-09-01 18:35:00'),
('mien-bac', '2026-09-02', 'PUBLISH', 10000000, '2026-09-02 18:35:00'),
('mien-bac', '2026-09-03', 'PUBLISH', 10000000, '2026-09-03 18:35:00'),
('mien-bac', '2026-09-04', 'PUBLISH', 10000000, '2026-09-04 18:35:00'),
('mien-bac', '2026-09-05', 'PUBLISH', 10000000, '2026-09-05 18:35:00'),
('mien-bac', '2026-09-06', 'PUBLISH', 10000000, '2026-09-06 18:35:00'),
('mien-bac', '2026-09-07', 'PUBLISH', 10000000, '2026-09-07 18:35:00'),
('mien-bac', '2026-09-08', 'PUBLISH', 10000000, '2026-09-08 18:35:00'),
('mien-bac', '2026-09-09', 'PUBLISH', 10000000, '2026-09-09 18:35:00'),
('mien-bac', '2026-09-10', 'UNPUBLISH', 10000000, '2026-09-10 18:35:00');

-- ---------------------------------------------------------------------
-- 6. lottery_ticket_items
-- ticket_id = 30000000 .. 30000009 (10 vé ở trên)
-- ---------------------------------------------------------------------
INSERT INTO lottery_ticket_items (ticket_id, prize_code, prize_name, prize_number) VALUES
-- 2026-09-01
(30000000, 'DB', 'Đặc biệt', '05521'),
(30000000, 'G1', 'Giải nhất', '69764'),
(30000000, 'G2', 'Giải nhì', '11984-25698'),
(30000000, 'G3', 'Giải ba', '24697-76719-65670-08302-47610-85931'),
(30000000, 'G4', 'Giải tư', '9017-8080-3768-3944'),
(30000000, 'G5', 'Giải năm', '6796-9705-8662-2052-6112-5873'),
(30000000, 'G6', 'Giải sáu', '874-177-239'),
(30000000, 'G7', 'Giải bảy', '63-93-51-68'),
-- 2026-09-02
(30000001, 'DB', 'Đặc biệt', '44542'),
(30000001, 'G1', 'Giải nhất', '70943'),
(30000001, 'G2', 'Giải nhì', '20944-30062'),
(30000001, 'G3', 'Giải ba', '60516-22853-65620-02493-52067-04270'),
(30000001, 'G4', 'Giải tư', '3422-1237-4540-1955'),
(30000001, 'G5', 'Giải năm', '9150-5572-7077-4767-4522-2340'),
(30000001, 'G6', 'Giải sáu', '261-232-249'),
(30000001, 'G7', 'Giải bảy', '15-64-32-10'),
-- 2026-09-03
(30000002, 'DB', 'Đặc biệt', '39511'),
(30000002, 'G1', 'Giải nhất', '23956'),
(30000002, 'G2', 'Giải nhì', '52156-38339'),
(30000002, 'G3', 'Giải ba', '02003-95975-57033-07934-95846-95188'),
(30000002, 'G4', 'Giải tư', '8846-7210-6567-2605'),
(30000002, 'G5', 'Giải năm', '9043-1126-9634-7326-1964-1077'),
(30000002, 'G6', 'Giải sáu', '897-347-118'),
(30000002, 'G7', 'Giải bảy', '08-44-73-71'),
-- 2026-09-04
(30000003, 'DB', 'Đặc biệt', '50066'),
(30000003, 'G1', 'Giải nhất', '71152'),
(30000003, 'G2', 'Giải nhì', '34677-11336'),
(30000003, 'G3', 'Giải ba', '31123-91287-35599-38872-70150-30636'),
(30000003, 'G4', 'Giải tư', '8795-2876-3557-6896'),
(30000003, 'G5', 'Giải năm', '1372-8325-0353-0211-7949-0185'),
(30000003, 'G6', 'Giải sáu', '053-732-243'),
(30000003, 'G7', 'Giải bảy', '06-14-74-88'),
-- 2026-09-05
(30000004, 'DB', 'Đặc biệt', '24037'),
(30000004, 'G1', 'Giải nhất', '26504'),
(30000004, 'G2', 'Giải nhì', '19394-38969'),
(30000004, 'G3', 'Giải ba', '82903-37511-66329-99426-71193-60084'),
(30000004, 'G4', 'Giải tư', '3797-1157-6770-9888'),
(30000004, 'G5', 'Giải năm', '1258-9028-1021-5867-7290-4791'),
(30000004, 'G6', 'Giải sáu', '313-293-339'),
(30000004, 'G7', 'Giải bảy', '88-59-31-21'),
-- 2026-09-06
(30000005, 'DB', 'Đặc biệt', '61435'),
(30000005, 'G1', 'Giải nhất', '22976'),
(30000005, 'G2', 'Giải nhì', '95986-94493'),
(30000005, 'G3', 'Giải ba', '83179-34863-27496-89117-69501-75773'),
(30000005, 'G4', 'Giải tư', '5528-2212-1420-6993'),
(30000005, 'G5', 'Giải năm', '4516-7885-0526-5573-3299-7937'),
(30000005, 'G6', 'Giải sáu', '547-245-468'),
(30000005, 'G7', 'Giải bảy', '58-64-38-33'),
-- 2026-09-07
(30000006, 'DB', 'Đặc biệt', '34990'),
(30000006, 'G1', 'Giải nhất', '17449'),
(30000006, 'G2', 'Giải nhì', '22762-01934'),
(30000006, 'G3', 'Giải ba', '61777-43441-29734-74940-97028-22603'),
(30000006, 'G4', 'Giải tư', '0057-3011-6708-6131'),
(30000006, 'G5', 'Giải năm', '6596-6848-8646-8334-6931-3871'),
(30000006, 'G6', 'Giải sáu', '752-063-164'),
(30000006, 'G7', 'Giải bảy', '48-16-50-19'),
-- 2026-09-08
(30000007, 'DB', 'Đặc biệt', '39687'),
(30000007, 'G1', 'Giải nhất', '11087'),
(30000007, 'G2', 'Giải nhì', '49527-38622'),
(30000007, 'G3', 'Giải ba', '66993-10460-56800-95137-90035-69715'),
(30000007, 'G4', 'Giải tư', '3189-2570-6022-4740'),
(30000007, 'G5', 'Giải năm', '6344-1715-3462-9550-4287-4903'),
(30000007, 'G6', 'Giải sáu', '839-806-295'),
(30000007, 'G7', 'Giải bảy', '08-38-60-07'),
-- 2026-09-09
(30000008, 'DB', 'Đặc biệt', '94504'),
(30000008, 'G1', 'Giải nhất', '41565'),
(30000008, 'G2', 'Giải nhì', '47395-45697'),
(30000008, 'G3', 'Giải ba', '33200-78957-43011-40736-17257-36013'),
(30000008, 'G4', 'Giải tư', '0541-2830-8910-8548'),
(30000008, 'G5', 'Giải năm', '3977-2971-0207-0906-6063-5504'),
(30000008, 'G6', 'Giải sáu', '907-786-870'),
(30000008, 'G7', 'Giải bảy', '18-20-87-62'),
-- 2026-09-10
(30000009, 'DB', 'Đặc biệt', '30981'),
(30000009, 'G1', 'Giải nhất', '44595'),
(30000009, 'G2', 'Giải nhì', '15134-94624'),
(30000009, 'G3', 'Giải ba', '72524-93899-92446-09406-70772-03966'),
(30000009, 'G4', 'Giải tư', '3889-7592-5148-3427'),
(30000009, 'G5', 'Giải năm', '0536-1737-5070-3178-5042-2443'),
(30000009, 'G6', 'Giải sáu', '284-294-624'),
(30000009, 'G7', 'Giải bảy', '53-94-14-47');

-- ---------------------------------------------------------------------
-- 7. lottery_history (10 lần dò, mỗi vé 1 lần; prize_amount lấy theo lottery_prize_configs miền BAC)
-- user_id = 10000001 (Nguyễn Việt Đức); dòng cuối là khách (user_id NULL)
-- ---------------------------------------------------------------------
INSERT INTO lottery_history (user_id, ticket_id, ticket_number, result_summary, prize_amount, checked_at) VALUES
(10000001, 30000000, '05521', 'Trúng Giải Đặc biệt', 500000000, '2026-09-01 19:00:00'),
(10000001, 30000001, '70943', 'Trúng Giải Nhất', 10000000, '2026-09-02 19:00:00'),
(10000001, 30000002, '52156', 'Trúng Giải Nhì', 5000000, '2026-09-03 19:00:00'),
(10000001, 30000003, '31123', 'Trúng Giải Ba', 1000000, '2026-09-04 19:00:00'),
(10000001, 30000004, '3797', 'Trúng Giải Tư', 400000, '2026-09-05 19:00:00'),
(10000001, 30000005, '4516', 'Trúng Giải Năm', 200000, '2026-09-06 19:00:00'),
(10000001, 30000006, '752', 'Trúng Giải Sáu', 100000, '2026-09-07 19:00:00'),
(10000001, 30000007, '38', 'Trúng Giải Bảy', 40000, '2026-09-08 19:00:00'),
(10000001, 30000008, '123456', 'Không trúng giải', NULL, '2026-09-09 19:00:00'),
(10000001, 30000008, '41565', 'Trúng Giải Nhất', 10000000, '2026-09-10 19:00:00');

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
SELECT * FROM lottery_regions;
SELECT * FROM lottery_companies;
SELECT * FROM lottery_prize_configs;
SELECT * FROM lottery_tickets;
SELECT * FROM lottery_ticket_items;
SELECT * FROM lottery_history;
