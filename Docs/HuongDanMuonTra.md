# Báo cáo mượn - trả (giải thích như sinh viên trình bày với giảng viên)

## Em đã triển khai những gì
- **Luồng nghiệp vụ ở BUS/MuonTraBUS.cs**: kiểm tra điều kiện đầu vào, lấy tham số quy định, rồi gọi DAO để ghi/đọc CSDL. Các hàm chính em viết/xài là `LapPhieuMuon`, `GiaHanPhieuMuon`, `TraPhieuMuon` và `LapPhieuTra`.
- **Tầng DAO/MuonTraDAO.cs**: em tách truy vấn MySQL, vừa lấy dữ liệu (độc giả, tham số, cuốn sách), vừa cập nhật trạng thái sách và chi tiết phiếu trong một transaction để không bị lệch dữ liệu.
- **DTO**: nhận dữ liệu từ DAO và tính toán sẵn số sách chưa trả, tình trạng hiển thị để UI chỉ việc binding.

## Cách em code từng chức năng
### 1) Lập phiếu mượn
1. Ở BUS em kiểm tra: mã độc giả không trống, danh sách cuốn hợp lệ; tính tuổi độc giả và hạn thẻ; đếm số sách đang giữ để không vượt quá `SoSachMuonToiDa`; đồng thời giới hạn ngày trả không vượt hạn thẻ hay số ngày mượn tối đa (quy định từ bảng THAMSO). 
2. Sau khi hợp lệ, em chuyển mã cuốn thành ID, gọi DAO `TaoPhieuMuonVaChiTiet`. Trong DAO, em sinh mã phiếu mới, chèn bản ghi vào **PHIEUMUON**, thêm chi tiết vào **CT_PHIEUMUON** và đặt `TinhTrang = 0` cho từng cuốn (đánh dấu đang mượn).
3. Kết quả trả về một `PhieuMuonDTO` đã tính sẵn `TongSach` và `SoSachChuaTra` để UI hiển thị tức thì.

### 2) Gia hạn phiếu
1. BUS kiểm tra số ngày gia hạn > 0, đảm bảo phiếu còn sách chưa trả, rồi cộng thêm ngày vào `NgayTraDuKien`.
2. DAO cập nhật trực tiếp cột `NgayTraDuKien` trong bảng **PHIEUMUON** để lưu hạn mới.
3. Em trả về `PhieuMuonDTO` đã cập nhật hạn, UI chỉ cần reload binding.

### 3) Trả sách
1. BUS nhận mã/ID phiếu, lấy tham số `DonGiaPhatMoiNgay`, rồi giao cho DAO tính phạt.
2. DAO lấy `NgayTraDuKien`, đếm cuốn chưa trả, tính số ngày trễ và tiền phạt mỗi cuốn; cập nhật `NgayTraThucTe`, `SoNgayTre`, `TienPhat` cho các dòng **CT_PHIEUMUON** và trả sách về `TinhTrang = 1`.
3. BUS trả về phiếu đã cập nhật để UI thông báo số tiền phạt.

### 4) Lập phiếu trả nhanh từ mã phiếu mượn
- Khi nhập mã phiếu mượn, BUS kiểm tra còn sách chưa trả, gọi lại logic `TraPhieuMuon` rồi gói dữ liệu thành `PhieuTraDTO` (bao gồm mã phiếu, độc giả, ngày trả, tổng sách, tổng phạt) để lưu log và hiển thị.

### 5) Import/Export Excel
- Em dùng `ClosedXML` để xuất danh sách phiếu mượn/trả ra Excel và để import lại. Khi import, mỗi dòng được parse và chuyển qua đúng hàm nghiệp vụ (`LapPhieuMuon` hoặc `LapPhieuTra`) nên vẫn đi qua đầy đủ kiểm tra.

## Nếu thầy hỏi sâu hơn
- Thầy có thể xem lại các hàm ở BUS để thấy rõ từng bước kiểm tra đầu vào, còn các truy vấn cụ thể và cập nhật trạng thái sách nằm ở DAO. Em thiết kế vậy để UI chỉ gọi BUS, không phải viết lại logic kiểm tra.
