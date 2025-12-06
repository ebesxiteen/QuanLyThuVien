namespace DTO
{
    public class LoanDetailDTO
    {
        public int MaPhieuMuon { get; set; }
        public int MaSach { get; set; }
        public int SoLuong { get; set; }
        public string? TinhTrangMuon { get; set; }

        public LoanDetailDTO() { }

        public LoanDetailDTO(int maPhieuMuon, int maSach, int soLuong, string? tinhTrangMuon = null)
        {
            MaPhieuMuon = maPhieuMuon;
            MaSach = maSach;
            SoLuong = soLuong;
            TinhTrangMuon = tinhTrangMuon;
        }
    }
}
