using System;

namespace DTO
{
    public class BookDTO
    {
        public int MaSach { get; set; }
        public string TieuDe { get; set; }
        public string ISBN { get; set; }
        public int NamXuatBan { get; set; }
        public decimal GiaSach { get; set; }
        public int SoLuongTong { get; set; }
        public int SoLuongCon { get; set; }
        public int MaNXB { get; set; }
        public int MaTheLoai { get; set; }
        public string? TinhTrangSach { get; set; }

        public BookDTO()
        {
            MaSach = 0;
            TieuDe = string.Empty;
            ISBN = string.Empty;
            NamXuatBan = 0;
            GiaSach = 0;
            SoLuongTong = 0;
            SoLuongCon = 0;
            MaNXB = 0;
            MaTheLoai = 0;
            TinhTrangSach = "Mới";
        }

        public BookDTO(int maSach, string tieuDe, string isbn, int namXuatBan,
                       decimal giaSach, int soLuongTong, int soLuongCon,
                       int maNXB, int maTheLoai, string? tinhTrangSach = "Mới")
        {
            MaSach = maSach;
            TieuDe = tieuDe;
            ISBN = isbn;
            NamXuatBan = namXuatBan;
            GiaSach = giaSach;
            SoLuongTong = soLuongTong;
            SoLuongCon = soLuongCon;
            MaNXB = maNXB;
            MaTheLoai = maTheLoai;
            TinhTrangSach = tinhTrangSach;
        }
    }
}
