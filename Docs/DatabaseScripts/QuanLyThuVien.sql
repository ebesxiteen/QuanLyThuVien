    
-- ===================================================
-- SCRIPT TẠO DATABASE HỆ THỐNG QUẢN LÝ THƯ VIỆN (MySQL)
-- ===================================================

-- Tạo database
DROP DATABASE IF EXISTS QuanLyThuVien;
CREATE DATABASE IF NOT EXISTS QuanLyThuVien CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE QuanLyThuVien;

-- ===================================================
-- TẠO CÁC BẢNG
-- ===================================================

-- Bảng Độc giả
CREATE TABLE DocGia (
    MaDocGia INT PRIMARY KEY AUTO_INCREMENT,
    HoTen VARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh VARCHAR(10),
    DiaChi VARCHAR(200),
    Email VARCHAR(100),
    SoDienThoai VARCHAR(20),
    NgayDangKy DATE DEFAULT (CURRENT_DATE)
);

-- Bảng Nhân viên
CREATE TABLE NhanVien (
    MaNhanVien INT PRIMARY KEY AUTO_INCREMENT,
    HoTen VARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh VARCHAR(10),
    DiaChi VARCHAR(200),
    SoDienThoai VARCHAR(20),
    NgayVaoLam DATE DEFAULT (CURRENT_DATE)
);

-- Bảng Thẻ thư viện
CREATE TABLE TheThuVien (
    MaThe INT PRIMARY KEY AUTO_INCREMENT,
    MaDocGia INT,
    NgayCap DATE DEFAULT (CURRENT_DATE),
    NgayHetHan DATE,	
    TrangThai VARCHAR(20) DEFAULT 'Hoạt động', -- Hoạt động / Bị khóa
    QRCode VARCHAR(255) -- Mã QR cho check-in online
);

-- Bảng Thể loại
CREATE TABLE TheLoai (
    MaTheLoai INT PRIMARY KEY AUTO_INCREMENT,
    TenTheLoai VARCHAR(100) NOT NULL,
    MoTa TEXT
);

-- Bảng Nhà xuất bản
CREATE TABLE NhaXuatBan (
    MaNXB INT PRIMARY KEY AUTO_INCREMENT,
    TenNXB VARCHAR(100) NOT NULL,
    DiaChi VARCHAR(200),
    SoDienThoai VARCHAR(20)
);

-- Bảng Tác giả
CREATE TABLE TacGia (
    MaTacGia INT PRIMARY KEY AUTO_INCREMENT,
    HoTen VARCHAR(100) NOT NULL,
    NgaySinh DATE,
    QuocTich VARCHAR(50)
);

-- Bảng Sách
CREATE TABLE Sach (
    MaSach INT PRIMARY KEY AUTO_INCREMENT,
    TieuDe VARCHAR(200) NOT NULL,
    ISBN VARCHAR(20),
    NamXuatBan INT,
    GiaSach DECIMAL(10,2),
    SoLuongTong INT DEFAULT 0,
    SoLuongCon INT DEFAULT 0,
    MaNXB INT,
    MaTheLoai INT,
    TinhTrangSach VARCHAR(200) DEFAULT 'Mới'
);

-- Bảng Sách - Tác giả (nhiều-nhiều)
CREATE TABLE Sach_TacGia (
    MaSach INT,
    MaTacGia INT,
    PRIMARY KEY (MaSach, MaTacGia)
);

-- Bảng Nhà cung cấp
CREATE TABLE NhaCungCap (
    MaNCC INT PRIMARY KEY AUTO_INCREMENT,
    TenNCC VARCHAR(100) NOT NULL,
    DiaChi VARCHAR(200),
    SoDienThoai VARCHAR(20)
);

-- Bảng Nhập sách
CREATE TABLE NhapSach (
    MaPhieuNhap INT PRIMARY KEY AUTO_INCREMENT,
    MaNCC INT,
    NgayNhap DATE DEFAULT (CURRENT_DATE),
    MaNhanVien INT,
    TongTien DECIMAL(10,2)
);

-- Bảng Chi tiết nhập sách
CREATE TABLE ChiTietNhapSach (
    MaPhieuNhap INT,
    MaSach INT,
    SoLuong INT,
    DonGia DECIMAL(10,2),
    PRIMARY KEY (MaPhieuNhap, MaSach)
);

-- Bảng Phiếu mượn
CREATE TABLE PhieuMuon (
    MaPhieuMuon INT PRIMARY KEY AUTO_INCREMENT,
    MaDocGia INT,
    MaNhanVien INT,
    NgayMuon DATE DEFAULT (CURRENT_DATE),
    HanTra DATE,
    TrangThai VARCHAR(20) DEFAULT 'Đang mượn'
);

-- Bảng Chi tiết mượn
CREATE TABLE ChiTietMuon (
    MaPhieuMuon INT,
    MaSach INT,
    SoLuong INT,
    TinhTrangMuon VARCHAR(200),
    PRIMARY KEY (MaPhieuMuon, MaSach)
);

-- Bảng Phiếu trả
CREATE TABLE PhieuTra (
    MaPhieuTra INT PRIMARY KEY AUTO_INCREMENT,
    MaPhieuMuon INT,
    NgayTra DATE DEFAULT (CURRENT_DATE),
    TinhTrangSach VARCHAR(100),
    TienPhat DECIMAL(10,2) DEFAULT 0
);

-- Bảng Chi tiết trả cho phép cập nhật tình trạng từng cuốn khi trả
CREATE TABLE ChiTietTra (
    MaPhieuTra INT,
    MaSach INT,
    TinhTrangTra VARCHAR(200),
    TienPhat DECIMAL(10,2) DEFAULT 0,
    PRIMARY KEY (MaPhieuTra, MaSach)
);

-- Bảng Tham số phạt để cấu hình các mức xử lý hư hỏng
CREATE TABLE ThamSoPhat (
    MaThamSoPhat INT PRIMARY KEY AUTO_INCREMENT,
    LoaiTinhTrang VARCHAR(50) NOT NULL,
    MucDo VARCHAR(100),
    MoTa TEXT,
    SoTien DECIMAL(10,2) NOT NULL DEFAULT 0
);

-- Bảng Phiếu phạt
CREATE TABLE PhieuPhat (
    MaPhieuPhat INT PRIMARY KEY AUTO_INCREMENT,
    MaPhieuTra INT,
    LyDo VARCHAR(200),
    SoTien DECIMAL(10,2),
    NgayLap DATE DEFAULT (CURRENT_DATE)
);

-- Bảng Đăng nhập
CREATE TABLE DangNhap (
    TenDangNhap VARCHAR(50) PRIMARY KEY,
    MatKhau VARCHAR(255) NOT NULL,
    VaiTro ENUM('DocGia','NhanVien') NOT NULL,
    MaDocGia INT NULL,
    MaNhanVien INT NULL
);
-- Bảng Đánh Giá Sách
CREATE TABLE DanhGiaSach (
    MaDanhGia INT PRIMARY KEY AUTO_INCREMENT,
    MaDocGia INT,
    MaSach INT,
    SoSao INT CHECK (SoSao BETWEEN 1 AND 5),
    NhanXet TEXT,
    NgayDanhGia DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (MaDocGia) REFERENCES DocGia(MaDocGia),
    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
);

-- Bảng Sự Kiện Thư Viện
CREATE TABLE SuKienThuVien (
    MaSuKien INT PRIMARY KEY AUTO_INCREMENT,
    TenSuKien VARCHAR(200) NOT NULL,
    MoTa TEXT,
    NgayBatDau DATE,
    NgayKetThuc DATE,
    DiaDiem VARCHAR(200),
    NguoiPhuTrach INT,
    FOREIGN KEY (NguoiPhuTrach) REFERENCES NhanVien(MaNhanVien)
);

-- Bảng Đăng Ký Sự Kiện
CREATE TABLE DangKySuKien (
    MaSuKien INT,
    MaDocGia INT,
    NgayDangKy DATE DEFAULT (CURRENT_DATE),
    PRIMARY KEY (MaSuKien, MaDocGia),
    FOREIGN KEY (MaSuKien) REFERENCES SuKienThuVien(MaSuKien),
    FOREIGN KEY (MaDocGia) REFERENCES DocGia(MaDocGia)
);

-- ===================================================
-- TẠO CÁC RÀNG BUỘC KHÓA NGOẠI
-- ===================================================

-- Khóa ngoại cho bảng TheThuVien
ALTER TABLE TheThuVien
ADD CONSTRAINT FK_TheThuVien_DocGia
FOREIGN KEY (MaDocGia) REFERENCES DocGia(MaDocGia);

-- Khóa ngoại cho bảng Sách
ALTER TABLE Sach
ADD CONSTRAINT FK_Sach_NhaXuatBan
FOREIGN KEY (MaNXB) REFERENCES NhaXuatBan(MaNXB);

ALTER TABLE Sach
ADD CONSTRAINT FK_Sach_TheLoai
FOREIGN KEY (MaTheLoai) REFERENCES TheLoai(MaTheLoai);

-- Khóa ngoại cho bảng Sach_TacGia
ALTER TABLE Sach_TacGia
ADD CONSTRAINT FK_SachTacGia_Sach
FOREIGN KEY (MaSach) REFERENCES Sach(MaSach);

ALTER TABLE Sach_TacGia
ADD CONSTRAINT FK_SachTacGia_TacGia
FOREIGN KEY (MaTacGia) REFERENCES TacGia(MaTacGia);

-- Khóa ngoại cho bảng NhapSach
ALTER TABLE NhapSach
ADD CONSTRAINT FK_NhapSach_NhaCungCap
FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC);

ALTER TABLE NhapSach
ADD CONSTRAINT FK_NhapSach_NhanVien
FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien);

-- Khóa ngoại cho bảng ChiTietNhapSach
ALTER TABLE ChiTietNhapSach
ADD CONSTRAINT FK_ChiTietNhapSach_NhapSach
FOREIGN KEY (MaPhieuNhap) REFERENCES NhapSach(MaPhieuNhap);

ALTER TABLE ChiTietNhapSach
ADD CONSTRAINT FK_ChiTietNhapSach_Sach
FOREIGN KEY (MaSach) REFERENCES Sach(MaSach);

-- Khóa ngoại cho bảng PhieuMuon
ALTER TABLE PhieuMuon
ADD CONSTRAINT FK_PhieuMuon_DocGia
FOREIGN KEY (MaDocGia) REFERENCES DocGia(MaDocGia);

ALTER TABLE PhieuMuon
ADD CONSTRAINT FK_PhieuMuon_NhanVien
FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien);

-- Khóa ngoại cho bảng ChiTietMuon
ALTER TABLE ChiTietMuon
ADD CONSTRAINT FK_ChiTietMuon_PhieuMuon
FOREIGN KEY (MaPhieuMuon) REFERENCES PhieuMuon(MaPhieuMuon);

ALTER TABLE ChiTietMuon
ADD CONSTRAINT FK_ChiTietMuon_Sach
FOREIGN KEY (MaSach) REFERENCES Sach(MaSach);

-- Khóa ngoại cho bảng PhieuTra
ALTER TABLE PhieuTra
ADD CONSTRAINT FK_PhieuTra_PhieuMuon
FOREIGN KEY (MaPhieuMuon) REFERENCES PhieuMuon(MaPhieuMuon);

ALTER TABLE ChiTietTra
ADD CONSTRAINT FK_ChiTietTra_PhieuTra
FOREIGN KEY (MaPhieuTra) REFERENCES PhieuTra(MaPhieuTra);

ALTER TABLE ChiTietTra
ADD CONSTRAINT FK_ChiTietTra_Sach
FOREIGN KEY (MaSach) REFERENCES Sach(MaSach);

-- Khóa ngoại cho bảng PhieuPhat
ALTER TABLE PhieuPhat
ADD CONSTRAINT FK_PhieuPhat_DocGia
FOREIGN KEY (MaPhieuTra) REFERENCES PhieuTra(MaPhieuTra);

-- Khóa ngoại cho bảng DangNhap
ALTER TABLE DangNhap
ADD CONSTRAINT FK_DangNhap_NhanVien
FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien);

ALTER TABLE DangNhap
ADD CONSTRAINT FK_DangNhap_DocGia
FOREIGN KEY (MaDocGia) REFERENCES DocGia(MaDocGia);

-- ===================================================
-- THÊM DỮ LIỆU MẪU
-- ===================================================

-- Thêm dữ liệu cho bảng NhanVien
INSERT INTO NhanVien (HoTen, NgaySinh, GioiTinh, DiaChi, SoDienThoai, NgayVaoLam) VALUES
(N'Nguyễn Văn An', '1985-06-15', N'Nam', N'123 Trần Hưng Đạo, Q1, TP.HCM', '0901234567', '2020-01-15'),
(N'Trần Thị Bình', '1990-03-22', N'Nữ', N'456 Lê Lợi, Q3, TP.HCM', '0912345678', '2021-05-10'),
(N'Lê Minh Cường', '1988-11-08', N'Nam', N'789 Nguyễn Huệ, Q1, TP.HCM', '0923456789', '2022-02-20');

-- Thêm dữ liệu cho bảng DocGia
INSERT INTO DocGia (HoTen, NgaySinh, GioiTinh, DiaChi, Email, SoDienThoai, NgayDangKy) VALUES
(N'Phạm Văn Đức', '1995-07-12', N'Nam', N'12 Võ Văn Tần, Q3, TP.HCM', 'ducpv@gmail.com', '0934567890', '2023-01-10'),
(N'Nguyễn Thị Esen', '1992-09-25', N'Nữ', N'34 Hai Bà Trưng, Q1, TP.HCM', 'esenngt@gmail.com', '0945678901', '2023-02-15'),
(N'Trần Minh Phúc', '1998-04-03', N'Nam', N'56 Điện Biên Phủ, Q3, TP.HCM', 'phuctm@gmail.com', '0956789012', '2023-03-20'),
(N'Lê Thị Giang', '1996-12-18', N'Nữ', N'78 Cách Mạng Tháng Tám, Q10, TP.HCM', 'gianglt@gmail.com', '0967890123', '2023-04-05'),
(N'Hoàng Văn Hùng', '1994-02-28', N'Nam', N'90 Nam Kỳ Khởi Nghĩa, Q1, TP.HCM', 'hunghv@gmail.com', '0978901234', '2023-05-12'),
(N'Nguyễn Văn An', '1990-03-12', 'Nam', N'12 Nguyễn Trãi, Q1, TP.HCM', 'annguyen90@gmail.com', '0912345678', '2023-01-18'),
(N'Trần Thị Hoa', '1993-07-25', 'Nữ', N'45 Trần Hưng Đạo, Q5, TP.HCM', 'hoatran93@gmail.com', '0923456789', '2023-02-22'),
(N'Lê Văn Bình', '1997-11-10', 'Nam', N'23 Lê Lai, Q1, TP.HCM', 'binhlv97@gmail.com', '0934567891', '2023-03-05'),
(N'Phạm Thị Lan', '1995-04-30', 'Nữ', N'67 Hai Bà Trưng, Q3, TP.HCM', 'lanpham95@gmail.com', '0945678901', '2023-03-28'),
(N'Đỗ Văn Khoa', '1992-09-14', 'Nam', N'89 Võ Thị Sáu, Q3, TP.HCM', 'khoado92@gmail.com', '0956789012', '2023-04-12'),
(N'Bùi Thị Hạnh', '1996-12-03', 'Nữ', N'101 Lý Thường Kiệt, Q10, TP.HCM', 'hanhbui96@gmail.com', '0967890123', '2023-05-06'),
(N'Nguyễn Văn Long', '1998-01-20', 'Nam', N'202 Cách Mạng Tháng 8, Q10, TP.HCM', 'longng98@gmail.com', '0978901234', '2023-05-18'),
(N'Hoàng Thị Mai', '1994-06-15', 'Nữ', N'35 Nguyễn Đình Chiểu, Q3, TP.HCM', 'maih94@gmail.com', '0989012345', '2023-06-22'),
(N'Trần Văn Sơn', '1991-08-09', 'Nam', N'78 Phạm Ngũ Lão, Q1, TP.HCM', 'sontran91@gmail.com', '0990123456', '2023-07-02'),
(N'Vũ Thị Ngọc', '1999-02-11', 'Nữ', N'12 Hoàng Hoa Thám, Q5, TP.HCM', 'ngocvu99@gmail.com', '0901234567', '2023-07-28'),
(N'Đặng Văn Phúc', '1989-10-18', 'Nam', N'45 Nguyễn Thị Minh Khai, Q1, TP.HCM', 'phucdv89@gmail.com', '0913456789', '2023-08-15'),
(N'Phạm Thị Hương', '1993-05-05', 'Nữ', N'56 Điện Biên Phủ, Q3, TP.HCM', 'huongpt93@gmail.com', '0924567890', '2023-08-29'),
(N'Nguyễn Văn Hiếu', '1997-12-22', 'Nam', N'78 Trần Quang Khải, Q1, TP.HCM', 'hieunv97@gmail.com', '0935678902', '2023-09-12'),
(N'Lê Thị Thu', '1996-03-08', 'Nữ', N'90 Võ Văn Tần, Q3, TP.HCM', 'thule96@gmail.com', '0946789013', '2023-09-28'),
(N'Hồ Văn Tài', '1992-11-16', 'Nam', N'120 Cách Mạng Tháng 8, Q10, TP.HCM', 'taihv92@gmail.com', '0957890124', '2023-10-10'),
(N'Nguyễn Thị Bích', '1995-01-27', 'Nữ', N'32 Lê Văn Sỹ, Q3, TP.HCM', 'bichnt95@gmail.com', '0968901235', '2023-10-24'),
(N'Trần Văn Quang', '1998-06-19', 'Nam', N'11 Phan Đăng Lưu, Q3, TP.HCM', 'quangtv98@gmail.com', '0979012346', '2023-11-05'),
(N'Đỗ Thị Mỹ', '1994-09-07', 'Nữ', N'22 Trương Định, Q3, TP.HCM', 'mydo94@gmail.com', '0980123457', '2023-11-19'),
(N'Nguyễn Văn Phát', '1991-04-13', 'Nam', N'56 Lê Hồng Phong, Q5, TP.HCM', 'phatnv91@gmail.com', '0991234568', '2023-12-02'),
(N'Hoàng Thị Lý', '1999-07-30', 'Nữ', N'78 Nguyễn Kiệm, Q.Phú Nhuận, TP.HCM', 'lyhoang99@gmail.com', '0902345678', '2023-12-20'),
(N'Nguyễn Văn Đức', '1990-05-21', 'Nam', N'23 Nguyễn Huệ, Q1, TP.HCM', 'ducnv90@gmail.com', '0914567890', '2024-01-08'),
(N'Trần Thị Đào', '1996-10-01', 'Nữ', N'45 Trần Quốc Toản, Q3, TP.HCM', 'daott96@gmail.com', '0925678901', '2024-01-22'),
(N'Lê Văn Hải', '1992-12-19', 'Nam', N'89 Lê Thánh Tôn, Q1, TP.HCM', 'hailv92@gmail.com', '0936789012', '2024-02-06'),
(N'Phạm Thị Yến', '1997-08-23', 'Nữ', N'67 Nguyễn Thị Minh Khai, Q3, TP.HCM', 'yenpt97@gmail.com', '0947890123', '2024-02-18'),
(N'Nguyễn Văn Kiên', '1994-02-14', 'Nam', N'12 Hoàng Diệu, Q4, TP.HCM', 'kiennv94@gmail.com', '0958901234', '2024-03-03');

-- Thêm dữ liệu cho bảng TheThuVien
INSERT INTO TheThuVien (MaDocGia, NgayCap, NgayHetHan, TrangThai, QRCode) VALUES
(1, '2023-01-10', '2025-01-10', 'Hoạt động', CONCAT('QR001_', UUID())),
(2, '2023-02-15', '2025-02-15', 'Hoạt động', CONCAT('QR002_', UUID())),
(3, '2023-03-20', '2025-03-20', 'Hoạt động', CONCAT('QR003_', UUID())),
(4, '2023-04-05', '2025-04-05', 'Hoạt động', CONCAT('QR004_', UUID())),
(5, '2023-05-12', '2025-05-12', 'Bị khóa',   CONCAT('QR005_', UUID()));

-- Thêm dữ liệu cho bảng TheLoai
INSERT INTO TheLoai (TenTheLoai, MoTa) VALUES
(N'Văn học', N'Sách về văn học trong nước và quốc tế'),
(N'Khoa học kỹ thuật', N'Sách về các lĩnh vực khoa học và kỹ thuật'),
(N'Kinh tế', N'Sách về kinh tế, quản trị kinh doanh'),
(N'Lịch sử', N'Sách về lịch sử Việt Nam và thế giới'),
(N'Tâm lý học', N'Sách về tâm lý học và phát triển bản thân'),
(N'Tin học', N'Sách về tin học và công nghệ thông tin'),
(N'Y học', N'Sách về y học và sức khỏe'),
(N'Giáo dục', N'Sách giáo khoa và tham khảo giáo dục');

-- Thêm dữ liệu cho bảng NhaXuatBan
INSERT INTO NhaXuatBan (TenNXB, DiaChi, SoDienThoai) VALUES
(N'NXB Trẻ', N'161B Lý Chính Thắng, Q3, TP.HCM', '0283932419'),
(N'NXB Kim Đồng', N'55 Quang Trung, Hai Bà Trưng, Hà Nội', '0243943568'),
(N'NXB Giáo dục Việt Nam', N'81 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', '0243822543'),
(N'NXB Lao động', N'175 Giảng Võ, Đống Đa, Hà Nội', '0243943361'),
(N'NXB Thông tin và Truyền thông', N'18 Nguyễn Du, Hai Bà Trưng, Hà Nội', '0243944359');

-- Thêm dữ liệu cho bảng TacGia
INSERT INTO TacGia (HoTen, NgaySinh, QuocTich) VALUES
(N'Nguyễn Nhật Ánh', '1955-05-07', N'Việt Nam'),
(N'Tô Hoài', '1920-09-27', N'Việt Nam'),
(N'Nam Cao', '1915-10-29', N'Việt Nam'),
(N'Haruki Murakami', '1949-01-12', N'Nhật Bản'),
(N'Paulo Coelho', '1947-08-24', N'Brazil'),
(N'Dale Carnegie', '1888-11-24', N'Mỹ'),
(N'Robert Kiyosaki', '1947-04-08', N'Mỹ'),
(N'Stephen Hawking', '1942-01-08', N'Anh');

-- Thêm dữ liệu cho bảng Sach
INSERT INTO Sach (TieuDe, ISBN, NamXuatBan, GiaSach, SoLuongTong, SoLuongCon, MaNXB, MaTheLoai, TinhTrangSach) VALUES
(N'Tôi thấy hoa vàng trên cỏ xanh', '978-604-2-08529-3', 2010, 89000, 15, 12, 1, 1, N'Mới'),
(N'Dế Mèn phiêu lưu ký', '978-604-2-13456-7', 2005, 65000, 20, 18, 2, 1, N'Mới'),
(N'Chí Phèo', '978-604-2-45678-9', 1941, 45000, 10, 8, 3, 1, N'Mới'),
(N'Kafka bên bờ biển', '978-604-2-78901-2', 2020, 125000, 8, 5, 1, 1, N'Mới'),
(N'Nhà giả kim', '978-604-2-34567-8', 2018, 95000, 12, 10, 4, 1, N'Mới'),
(N'Đắc nhân tâm', '978-604-2-56789-0', 2019, 78000, 25, 22, 4, 5, N'Mới'),
(N'Cha giàu cha nghèo', '978-604-2-67890-1', 2017, 110000, 18, 15, 4, 3, N'Mới'),
(N'Lược sử thời gian', '978-604-2-89012-3', 2016, 135000, 6, 4, 5, 2, N'Mới');

-- Thêm dữ liệu cho bảng Sach_TacGia
INSERT INTO Sach_TacGia (MaSach, MaTacGia) VALUES
(1, 1), -- Tôi thấy hoa vàng trên cỏ xanh - Nguyễn Nhật Ánh
(2, 2), -- Dế Mèn phiêu lưu ký - Tô Hoài
(3, 3), -- Chí Phèo - Nam Cao
(4, 4), -- Kafka bên bờ biển - Haruki Murakami
(5, 5), -- Nhà giả kim - Paulo Coelho
(6, 6), -- Đắc nhân tâm - Dale Carnegie
(7, 7), -- Cha giàu cha nghèo - Robert Kiyosaki
(8, 8); -- Lược sử thời gian - Stephen Hawking

-- Thêm dữ liệu cho bảng NhaCungCap
INSERT INTO NhaCungCap (TenNCC, DiaChi, SoDienThoai) VALUES
(N'Công ty Sách Fahasa', N'60-62 Lê Lợi, Q1, TP.HCM', '02838225798'),
(N'Công ty Nhã Nam', N'59 Đỗ Quang, Cầu Giấy, Hà Nội', '02436269018'),
(N'Công ty Alphabooks', N'14 Phan Đăng Lưu, Phú Nhuận, TP.HCM', '02838454059');

-- Thêm dữ liệu cho bảng NhapSach
INSERT INTO NhapSach (MaNCC, NgayNhap, MaNhanVien, TongTien) VALUES
(1, '2023-01-15', 1, 2500000),
(2, '2023-02-20', 2, 1800000),
(3, '2023-03-10', 1, 3200000);

-- Thêm dữ liệu cho bảng ChiTietNhapSach
INSERT INTO ChiTietNhapSach (MaPhieuNhap, MaSach, SoLuong, DonGia) VALUES
(1, 1, 15, 75000), -- Tôi thấy hoa vàng trên cỏ xanh
(1, 6, 25, 65000), -- Đắc nhân tâm
(2, 2, 20, 55000), -- Dế Mèn phiêu lưu ký
(2, 5, 12, 85000), -- Nhà giả kim
(3, 4, 8, 110000), -- Kafka bên bờ biển
(3, 7, 18, 95000), -- Cha giàu cha nghèo
(3, 8, 6, 120000); -- Lược sử thời gian

-- Thêm dữ liệu cho bảng PhieuMuon
INSERT INTO PhieuMuon (MaDocGia, MaNhanVien, NgayMuon, HanTra, TrangThai) VALUES
(1, 2, '2023-06-01', '2023-06-15', N'Đã trả'),
(2, 1, '2023-06-05', '2023-06-19', N'Đang mượn'),
(3, 2, '2023-06-10', '2023-06-24', N'Đang mượn'),
(4, 1, '2023-06-12', '2023-06-26', N'Quá hạn'),
(1, 2, '2023-06-20', '2023-07-04', N'Đang mượn');

-- Thêm dữ liệu cho bảng ChiTietMuon
INSERT INTO ChiTietMuon (MaPhieuMuon, MaSach, SoLuong, TinhTrangMuon) VALUES
(1, 1, 1, N'Mới'), -- Phiếu mượn 1: Tôi thấy hoa vàng trên cỏ xanh
(1, 6, 1, N'Mới'), -- Phiếu mượn 1: Đắc nhân tâm
(2, 2, 1, N'Mới'), -- Phiếu mượn 2: Dế Mèn phiêu lưu ký
(2, 5, 1, N'Mới'), -- Phiếu mượn 2: Nhà giả kim
(3, 4, 1, N'Mới'), -- Phiếu mượn 3: Kafka bên bờ biển
(4, 7, 1, N'Mới'), -- Phiếu mượn 4: Cha giàu cha nghèo
(4, 8, 1, N'Mới'), -- Phiếu mượn 4: Lược sử thời gian
(5, 3, 1, N'Mới'); -- Phiếu mượn 5: Chí Phèo

-- Thêm dữ liệu tham số phạt
INSERT INTO ThamSoPhat (LoaiTinhTrang, MucDo, MoTa, SoTien) VALUES
(N'Mới', NULL, N'Sách còn mới, không phạt', 0),
(N'Bẩn', NULL, N'Sách bị bẩn, phạt cố định', 10000),
(N'Ướt', NULL, N'Sách bị ướt, cần sấy và ép lại', 15000),
(N'Rách', N'Dưới 3 trang', N'Rách nhẹ, dán lại được', 20000),
(N'Rách', N'3 - 5 trang', N'Rách mức trung bình', 40000),
(N'Rách', N'Trên 5 trang', N'Rách nặng, cân nhắc thay mới', 70000),
(N'Mất', NULL, N'Mất sách, bồi hoàn toàn bộ', 200000);

-- Thêm dữ liệu chi tiết trả mẫu
INSERT INTO ChiTietTra (MaPhieuTra, MaSach, TinhTrangTra, TienPhat) VALUES
(1, 1, N'Mới', 0),
(2, 2, N'Mới', 0);

-- Thêm dữ liệu cho bảng PhieuTra
INSERT INTO PhieuTra (MaPhieuMuon, NgayTra, TinhTrangSach, TienPhat) VALUES
(1, '2023-06-14', N'Tốt', 0),
(2, '2023-06-14', N'Tốt', 0); -- Trả đúng hạn

-- Thêm dữ liệu cho bảng PhieuPhat
INSERT INTO PhieuPhat (MaPhieuTra, LyDo, SoTien, NgayLap) VALUES
(1, N'Trả sách quá hạn 5 ngày', 50000, '2023-07-01'),
(2, N'Làm hỏng sách', 120000, '2023-06-25');

-- Thêm dữ liệu cho bảng DangNhap
INSERT INTO DangNhap (TenDangNhap, MatKhau, VaiTro, MaDocGia, MaNhanVien) VALUES
('admin', '123456', 'NhanVien', NULL, 1),
('thutkhu1', '123456', 'NhanVien', NULL, 2),
('kythuat1', '123456', 'NhanVien', NULL, 3),
('docgia001', '123456', 'DocGia', 1, NULL),
('docgia002', '123456', 'DocGia', 2, NULL),
('docgia003', '123456', 'DocGia', 3, NULL),
('docgia004', '123456', 'DocGia', 4, NULL),
('docgia005', '123456', 'DocGia', 5, NULL);
-- Dữ liệu mẫu cho bảng DanhGiaSach
INSERT INTO DanhGiaSach (MaDocGia, MaSach, SoSao, NhanXet, NgayDanhGia)
VALUES
(1, 2, 5, 'Sách rất hay, nội dung bổ ích và dễ hiểu.', '2025-09-20'),
(2, 4, 4, 'Trình bày rõ ràng, tuy hơi dài dòng.', '2025-09-22'),
(3, 1, 3, 'Nội dung ổn nhưng hơi khó đọc.', '2025-09-25'),
(1, 5, 5, 'Một trong những cuốn sách hay nhất tôi từng đọc.', '2025-09-27');
-- Dữ liệu mẫu cho bảng SuKienThuVien
INSERT INTO SuKienThuVien (TenSuKien, MoTa, NgayBatDau, NgayKetThuc, DiaDiem, NguoiPhuTrach)
VALUES
('Ngày Hội Đọc Sách', 'Sự kiện khuyến khích thói quen đọc sách cho học sinh, sinh viên.', '2025-10-05', '2025-10-07', 'Hội trường A', 1),
('Triển Lãm Sách Quý', 'Trưng bày các đầu sách quý hiếm và đặc biệt.', '2025-11-01', '2025-11-03', 'Phòng triển lãm', 2),
('Hội Thảo Văn Học', 'Gặp gỡ, trao đổi với các nhà văn nổi tiếng.', '2025-12-10', '2025-12-10', 'Phòng họp lớn', 3);
-- Dữ liệu mẫu cho bảng DangKySuKien
INSERT INTO DangKySuKien (MaSuKien, MaDocGia, NgayDangKy)
VALUES
(1, 1, '2025-10-01'),
(1, 2, '2025-10-02'),
(2, 3, '2025-10-25'),
(3, 1, '2025-12-01'),
(3, 2, '2025-12-02');


-- ===================================================
-- TRIGGER CẬP NHẬT SỐ LƯỢNG SÁCH
-- ===================================================

-- Trigger cập nhật số lượng sách khi nhập
DELIMITER $$
CREATE TRIGGER trg_UpdateSachAfterNhap
AFTER INSERT ON ChiTietNhapSach
FOR EACH ROW
BEGIN
    UPDATE Sach
    SET SoLuongTong = SoLuongTong + NEW.SoLuong,
        SoLuongCon = SoLuongCon + NEW.SoLuong
    WHERE MaSach = NEW.MaSach;
END$$
DELIMITER ;

-- Trigger cập nhật số lượng sách khi mượn
DELIMITER $$
CREATE TRIGGER trg_UpdateSachAfterMuon
AFTER INSERT ON ChiTietMuon
FOR EACH ROW
BEGIN
    UPDATE Sach
    SET SoLuongCon = SoLuongCon - NEW.SoLuong
    WHERE MaSach = NEW.MaSach;
END$$
DELIMITER ;

-- Trigger cập nhật số lượng sách khi trả
DELIMITER $$
CREATE TRIGGER trg_UpdateSachAfterTra
AFTER INSERT ON PhieuTra
FOR EACH ROW
BEGIN
    UPDATE Sach s
    INNER JOIN ChiTietMuon ct ON NEW.MaPhieuMuon = ct.MaPhieuMuon
    SET s.SoLuongCon = s.SoLuongCon + ct.SoLuong
    WHERE s.MaSach = ct.MaSach;
END$$
DELIMITER ;

-- ===================================================
-- STORED PROCEDURES
-- ===================================================

-- Procedure tìm kiếm sách
DELIMITER $$
CREATE PROCEDURE sp_TimKiemSach(
    IN p_TuKhoa VARCHAR(200)
)
BEGIN
    SELECT s.MaSach, s.TieuDe, s.ISBN, s.NamXuatBan, s.GiaSach, 
           s.SoLuongTong, s.SoLuongCon,
           tl.TenTheLoai, nxb.TenNXB,
           GROUP_CONCAT(tg.HoTen SEPARATOR ', ') AS TacGia
    FROM Sach s
    LEFT JOIN TheLoai tl ON s.MaTheLoai = tl.MaTheLoai
    LEFT JOIN NhaXuatBan nxb ON s.MaNXB = nxb.MaNXB
    LEFT JOIN Sach_TacGia stg ON s.MaSach = stg.MaSach
    LEFT JOIN TacGia tg ON stg.MaTacGia = tg.MaTacGia
    WHERE s.TieuDe LIKE CONCAT('%', p_TuKhoa, '%')
       OR tg.HoTen LIKE CONCAT('%', p_TuKhoa, '%')
       OR tl.TenTheLoai LIKE CONCAT('%', p_TuKhoa, '%')
    GROUP BY s.MaSach, s.TieuDe, s.ISBN, s.NamXuatBan, s.GiaSach, 
             s.SoLuongTong, s.SoLuongCon, tl.TenTheLoai, nxb.TenNXB
    ORDER BY s.TieuDe;
END$$
DELIMITER ;

-- Procedure báo cáo sách được mượn nhiều nhất
DELIMITER $$
CREATE PROCEDURE sp_BaoCaoSachPhoBien(
    IN p_NgayBatDau DATE,
    IN p_NgayKetThuc DATE,
    IN p_Top INT
)
BEGIN
    IF p_Top IS NULL THEN
        SET p_Top = 10;
    END IF;
    
    SELECT s.MaSach, s.TieuDe, 
           COUNT(ct.MaSach) AS SoLanMuon,
           SUM(ct.SoLuong) AS TongSoLuongMuon
    FROM Sach s
    INNER JOIN ChiTietMuon ct ON s.MaSach = ct.MaSach
    INNER JOIN PhieuMuon pm ON ct.MaPhieuMuon = pm.MaPhieuMuon
    WHERE pm.NgayMuon BETWEEN p_NgayBatDau AND p_NgayKetThuc
    GROUP BY s.MaSach, s.TieuDe
    ORDER BY COUNT(ct.MaSach) DESC, SUM(ct.SoLuong) DESC
    LIMIT p_Top;
END$$
DELIMITER ;

SELECT 'Script tạo database và dữ liệu mẫu đã hoàn thành!' AS KetQua;
SELECT '- Đã tạo 13 bảng với đầy đủ ràng buộc khóa ngoại' AS ThongTin;
SELECT '- Đã thêm dữ liệu mẫu cho tất cả các bảng' AS ThongTin;
SELECT '- Đã tạo trigger tự động cập nhật số lượng sách' AS ThongTin;
SELECT '- Đã tạo stored procedure hỗ trợ tìm kiếm và báo cáo' AS ThongTin;
