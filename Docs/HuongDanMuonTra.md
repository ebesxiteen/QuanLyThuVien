# Báo cáo mượn - trả (giải thích như sinh viên trình bày với giảng viên)

## Sơ đồ file liên quan
- **BUS/MuonTraBUS.cs**: lớp nghiệp vụ; kiểm tra đầu vào, áp dụng quy định, gọi DAO và định nghĩa hàm import/export Excel.
- **DAO/MuonTraDAO.cs**: truy vấn MySQL và transaction để tạo/xóa/gia hạn/trả phiếu và cập nhật trạng thái cuốn sách.
- **DTO/MuonTraDTO.cs**: các lớp dữ liệu hiển thị, tự tính tình trạng (đang mượn/quá hạn/đã trả) và ghi chú.

## Giải thích từng hàm (theo thứ tự file và số dòng)
### BUS/MuonTraBUS.cs
- `LapPhieuMuon` (L24–74):
  - L24–29: kiểm tra mã độc giả và danh sách mã cuốn không được trống trước khi làm gì thêm.
  - L31–33: lấy thông tin độc giả từ DAO; nếu không có thì dừng ngay.
  - L35–38: lấy tham số quy định, tính tuổi thực tế (giảm một năm nếu chưa qua sinh nhật).
  - L40–45: chặn độc giả không đủ/ vượt tuổi quy định hoặc thẻ đã hết hạn.
  - L47–49: đếm số sách đang giữ; nếu mượn thêm vượt `SoSachMuonToiDa` thì báo lỗi.
  - L51–60: duyệt từng mã cuốn nhập vào, tra ID, kiểm tra tình trạng sẵn sàng; nếu ok thì đưa vào danh sách ID.
  - L62–71: đặt ngày mượn = hôm nay, tính hạn trả mặc định, ràng buộc ngày trả dự kiến không lùi so với ngày mượn, không vượt quy định và không quá ngày hết hạn thẻ.
  - L73: gọi DAO `TaoPhieuMuonVaChiTiet` để lưu DB và trả DTO cho UI.
- `TinhHanTraMacDinh` (L76–87): bóc tham số từ DAO và cộng `SoNgayMuonToiDa` vào ngày mượn (nếu 0 thì giữ nguyên).
- `GiaHanPhieuMuon` (L89–106):
  - L91–97: kiểm tra số ngày gia hạn > 0, phiếu tồn tại và vẫn còn sách chưa trả.
  - L99–105: cộng thêm ngày vào hạn, gọi DAO `GiaHanPhieuMuon`; nếu thành công thì cập nhật DTO tại chỗ và trả về.
- `TraPhieuMuon` (L108–121):
  - L110–112: lấy phiếu theo ID và tham số phạt mỗi ngày; nếu thiếu phiếu thì ném lỗi.
  - L114–117: gọi DAO `TraPhieuMuon` để cập nhật ngày trả, số ngày trễ, tiền phạt và trạng thái cuốn; nếu thất bại thì báo lỗi.
  - L119–120: đọc lại phiếu sau khi cập nhật để trả về DTO mới nhất.
- `LayPhieuMuonTheoID/Ma`, `LayTatCaPhieuMuon`, `LayChiTietPhieuMuon` (L123–148): chỉ chuyển tiếp gọi DAO để UI lấy dữ liệu.
- `XoaPhieuMuon` (L134–137): chuyển tiếp lệnh xóa sang DAO (DAO tự khóa khi đã có lịch sử trả).
- `LapPhieuTra` (L154–176):
  - L156–163: kiểm tra mã phiếu mượn nhập vào, đảm bảo còn sách chưa trả.
  - L165–175: tái dùng `TraPhieuMuon` để cập nhật DB, sau đó đóng gói thông tin trả (độc giả, ngày trả, số sách, tiền phạt) thành `PhieuTraDTO` để UI hiển thị nhanh.
- `ExportPhieuMuonToExcel` và `ExportPhieuTraToExcel` (L178–238): tạo workbook ClosedXML, điền tiêu đề (hàng 1), sau đó lặp danh sách phiếu để ghi dữ liệu từng dòng rồi lưu vào mảng byte.
- `ImportPhieuMuonFromExcel` (L240–279):
  - L245–249: đọc file Excel, lấy range đã dùng; nếu rỗng thì trả danh sách trống.
  - L250–276: bỏ qua dòng tiêu đề, với từng dòng: đọc mã độc giả, danh sách mã cuốn, ngày trả dự kiến; tách các mã cuốn bằng dấu phẩy/chấm phẩy/xuống dòng; chuyển qua `LapPhieuMuon`. Bất kỳ lỗi nào sẽ tăng bộ đếm thất bại.
- `ImportPhieuTraFromExcel` (L281–312): tương tự nhưng đọc mã phiếu mượn (cột 1), bỏ qua dòng trống, gọi `LapPhieuTra`; lỗi tăng bộ đếm thất bại.

### DAO/MuonTraDAO.cs
- `LayThamSoMuonTra` (L18–28): truy vấn bảng `THAMSO` lấy giới hạn sách/ngày/tuổi/phí phạt; nếu chưa cấu hình thì ném lỗi để BUS biết.
- `LayThongTinDocGia` (L30–35): lấy dữ liệu độc giả (ID, mã, họ tên, ngày sinh, hạn thẻ, tổng nợ) theo mã nhập.
- `LayIDCuonSach` (L37–42) & `CuonSachSanSang` (L44–50): tra ID cuốn và kiểm tra cột `TinhTrang` (1 = sẵn sàng, 0 = đang mượn).
- `DemSoSachDangMuon` (L52–59): đếm chi tiết phiếu mượn chưa có `NgayTraThucTe` của độc giả để kiểm soát giới hạn mượn.
- `TaoMaPhieuMuonMoi` (L61–74): trong transaction, lấy mã phiếu mượn cuối cùng, tăng số thứ tự và format `PMxxxxxx`.
- `TaoPhieuMuonVaChiTiet` (L76–130):
  - L81–87: mở transaction, sinh mã mới và chèn bản ghi **PHIEUMUON**, lấy `ID` vừa tạo.
  - L101–110: lặp từng ID cuốn, chèn vào **CT_PHIEUMUON** và đặt `TinhTrang = 0` cho cuốn (đánh dấu đang mượn).
  - L112–123: dựng `PhieuMuonDTO` kết quả (mã, độc giả, ngày mượn, hạn trả, tổng sách), trả về sau khi transaction thành công; nếu fail thì ném lỗi.
- `LayTatCaPhieuMuon` / `LayPhieuMuonTheoID` / `LayPhieuMuonTheoMa` (L132–178): truy vấn gộp **PHIEUMUON** với độc giả và chi tiết để tính `TongSach`, `SoSachChuaTra`, `NgayTraThucTe` cho màn danh sách và tìm kiếm.
- `LayChiTietPhieuMuon` (L180–192): lấy từng cuốn của phiếu, kèm tên tựa sách và hạn trả để hiển thị chi tiết.
- `GiaHanPhieuMuon` (L194–199): cập nhật cột `NgayTraDuKien` trong **PHIEUMUON**.
- `XoaPhieuMuon` (L202–230): trong transaction, chặn xóa nếu đã có lịch sử trả; xóa chi tiết, mở khóa `TinhTrang = 1` cho các cuốn, rồi xóa bản ghi phiếu.
- `TraPhieuMuon` (L232–274):
  - L237–243: lấy `NgayTraDuKien`; nếu mất dữ liệu thì trả false để BUS báo lỗi.
  - L244–247: lấy danh sách cuốn chưa trả.
  - L248–250: tính số ngày trễ và tiền phạt mỗi cuốn dựa trên `donGiaPhatMoiNgay`; tổng phạt = phạt mỗi cuốn × số cuốn chưa trả.
  - L252–261: cập nhật **CT_PHIEUMUON**: set `NgayTraThucTe`, `SoNgayTre`, `TienPhat` cho các dòng chưa trả.
  - L263–267: đặt lại `TinhTrang = 1` cho các cuốn vừa trả để cho phép mượn lại.
- `LayTatCaPhieuTra` (L276–292): gom các chi tiết đã trả theo phiếu, tính ngày trả mới nhất, tổng số sách trả và tổng tiền phạt.
- `LayChiTietPhieuTra` (L294–309): trả về từng cuốn đã trả kèm số ngày trễ và tiền phạt hiển thị trong màn phiếu trả.
- `XoaPhieuTra` (L311–334): đảm bảo phiếu đã có sách trả; nếu có thì xóa thông tin trả khỏi chi tiết và set trạng thái cuốn về 0 (đang mượn) để khôi phục trước khi trả.

### DTO/MuonTraDTO.cs
- `PhieuMuonDTO` (L5–35): giữ thông tin phiếu; property `TinhTrang` (L17–30) tự suy luận "Quá hạn" nếu còn sách và đã quá hạn trả, "Đang mượn" nếu còn sách nhưng chưa quá hạn, còn lại "Đã trả". `GhiChu` (L33–35) hiển thị tỷ lệ sách chưa trả.
- `ChiTietPhieuMuonDTO` (L38–46): mỗi cuốn trong phiếu mượn, gồm mã cuốn, tên sách, hạn trả và ngày trả thực tế (nếu có).
- `PhieuTraDTO` (L48–56): thông tin tóm tắt khi lập phiếu trả (mã phiếu mượn, độc giả, ngày trả, tổng sách, tổng tiền phạt).
- `ChiTietPhieuTraDTO` (L59–67): chi tiết từng cuốn đã trả, kèm số ngày trễ và tiền phạt tương ứng.
- `ThamSoMuonTraDTO` (L70–76): gói các quy định hệ thống (số sách tối đa, ngày mượn tối đa, đơn giá phạt, tuổi giới hạn).
- `DocGiaMuonInfoDTO` (L79–86): dữ liệu độc giả cần cho bước lập phiếu (ID, mã, họ tên, ngày sinh, hạn thẻ, tổng nợ hiện tại).

### GUI (UserControl & Form)
- **UCPhieuMuon.cs** (danh sách phiếu mượn):
  - Khởi động `UCPhieuMuon_Load` (L26–51) cấu hình DataGridView, gắn event nút (xem/trả/xóa) và gọi `LoadData` để lấy danh sách từ `MuonTraBUS.LayTatCaPhieuMuon` (L76–86).
  - Bộ lọc `ApplyFilters` (L96–139) tìm theo từ khóa, trạng thái "Đang mượn/Đã trả"; được gọi khi gõ ô tìm kiếm (L61–64) hoặc đổi combobox trạng thái (L66–69) và sau khi nạp dữ liệu.
  - `KhoiTaoCheDoNguoiDung` (L151–171) đọc quyền từ `SessionManager`, ẩn/hiện nút thêm/xóa/trả, và nếu là độc giả thì chỉ hiển thị phiếu của riêng mình (lọc ngay trong `LoadData`).
  - Nút **Thêm** gọi `MoFormThemPhieuMuon` (L141–149) → mở `FrmLapPhieuMuon`, nhận `PhieuMoi` đã tạo rồi thêm vào `BindingList` và báo mã phiếu mới.
  - Nút **Gia hạn** trên lưới kích hoạt `DgvPhieuMuon_ExtendButtonClicked` (L246–251) → `GiaHanPhieuMuonDuocChon` (L173–192) mở `FrmGiaHanPhieuMuon` với phiếu đang chọn, sau khi gia hạn thì refresh dữ liệu hiển thị.
  - Nút **Trả sách** trên lưới kích hoạt `DgvPhieuMuon_ReturnButtonClicked` (L253–258) → `TraPhieuMuonDuocChon` (L194–224) mở `FrmLapPhieuTra`, sau khi trả thành công đọc lại phiếu qua `MuonTraBUS.LayPhieuMuonTheoMa` để cập nhật số sách còn và hiện thông báo tiền phạt (nếu có).
  - Nút **Xóa** kích hoạt `DgvPhieuMuon_DeleteButtonClicked` (L260–265) → `XoaPhieuMuonDuocChon` (L267–294) xác nhận, gọi `MuonTraBUS.XoaPhieuMuon`, rồi gỡ item khỏi danh sách và áp lại bộ lọc.
  - Nút **Export/Import** (L301–339) dùng `MuonTraBUS.ExportPhieuMuonToExcel`/`ImportPhieuMuonFromExcel` để lưu/đọc Excel; sau khi import sẽ `LoadData` và báo số bản ghi thành công/thất bại.

- **UCPhieuTra.cs** (danh sách phiếu trả):
  - `UCPhieuTra_Load` (L26–45) cấu hình lưới, gắn event xem/xóa, gọi `LoadData` (L55–66) để lấy dữ liệu từ `MuonTraBUS.LayTatCaPhieuTra`, lọc theo độc giả đang đăng nhập nếu là người đọc.
  - Hàm `Filter` (L73–89) lọc theo mã phiếu/độc giả; được gọi khi nhập ô tìm kiếm (L68–71) và sau khi `LoadData`.
  - `KhoiTaoCheDoNguoiDung` (L138–155) ẩn/hiện nút lập phiếu trả, nút xóa và import/export dựa trên quyền.
  - Nút **Lập phiếu trả** (L91–99) mở `FrmLapPhieuTra`; nếu trả thành công thì nạp lại danh sách.
  - Nút **Xem** trên lưới (L101–108) mở `FrmChiTietPhieuTra` với DTO đã chọn.
  - Nút **Xóa** (L110–136) xác nhận rồi gọi `MuonTraBUS.XoaPhieuTra`; sau khi xóa thành công nạp lại dữ liệu và báo người dùng.
  - Nút **Export/Import** (L157–195) dùng BUS để xuất/nhập Excel tương tự phần phiếu mượn.

- **FrmLapPhieuMuon.cs** (form tạo phiếu mượn): `InitializeComponent` (L23–116) dựng UI, thêm sự kiện nút "Thêm mã", "Thêm hàng loạt", "Xóa mã" để thao tác danh sách mã cuốn `_maCuon`. Nút **Tạo phiếu** (L80–104) lấy mã độc giả, danh sách `_maCuon`, hạn trả (nếu người dùng chỉnh) rồi gọi `MuonTraBUS.LapPhieuMuon`; nếu thành công thì đặt `DialogResult.OK` và gán `PhieuMoi` để `UCPhieuMuon` nhận.

- **FrmGiaHanPhieuMuon.cs**: Nút **Lưu** (L18–34) đọc số ngày từ `numSoNgay`, gọi `MuonTraBUS.GiaHanPhieuMuon`, cập nhật `NgayTraDuKien` vào DTO gốc rồi trả `DialogResult.OK` cho `UCPhieuMuon` refresh.

- **FrmLapPhieuTra.cs**: 
  - `btnTaiPhieu_Click` (L37–60) nạp phiếu mượn theo mã từ textbox bằng `MuonTraBUS.LayPhieuMuonTheoMa`, hiển thị thông tin độc giả, hạn trả và `TinhTrang`, đồng thời tải chi tiết sách qua `MuonTraBUS.LayChiTietPhieuMuon` vào lưới.
  - `btnTaoPhieu_Click` (L63–84) gọi `MuonTraBUS.LapPhieuTra` để trả sách, nhận tiền phạt và cập nhật trạng thái hiển thị; đặt `DialogResult.OK` để `UCPhieuMuon` biết cần refresh khi được mở từ nút Trả.

## Cách tìm nhanh trên code
- Mở **BUS/MuonTraBUS.cs** để xem các bước kiểm tra và gọi DAO cho từng thao tác (mượn/gia hạn/trả/xóa/import/export).
- Mở **DAO/MuonTraDAO.cs** để đọc truy vấn SQL và thấy transaction xử lý trạng thái cuốn sách.
- Mở **DTO/MuonTraDTO.cs** để biết các field và cách tính tình trạng hiển thị mà UI binding.
