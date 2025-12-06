using DTO;
using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;
using System.ComponentModel;

namespace DAO
{
    public class BookDAO
    {
        // Lấy danh sách tất cả sách
        public static BindingList<BookDTO> GetAllBooks()
        {
            BindingList<BookDTO> list = new BindingList<BookDTO>();

            string query = "SELECT * FROM Sach";
            DataTable dt = DataProvider.Instance.ExecuteQuery(query);

            foreach (DataRow row in dt.Rows)
            {
                list.Add(new BookDTO
                {
                    MaSach = Convert.ToInt32(row["MaSach"]),
                    TieuDe = row["TieuDe"]?.ToString() ?? string.Empty,
                    ISBN = row["ISBN"]?.ToString() ?? string.Empty,
                    NamXuatBan = row["NamXuatBan"] == DBNull.Value ? 0 : Convert.ToInt32(row["NamXuatBan"]),
                    GiaSach = row["GiaSach"] == DBNull.Value ? 0 : Convert.ToDecimal(row["GiaSach"]),
                    SoLuongTong = row["SoLuongTong"] == DBNull.Value ? 0 : Convert.ToInt32(row["SoLuongTong"]),
                    SoLuongCon = row["SoLuongCon"] == DBNull.Value ? 0 : Convert.ToInt32(row["SoLuongCon"]),
                    MaNXB = row["MaNXB"] == DBNull.Value ? 0 : Convert.ToInt32(row["MaNXB"]),
                    MaTheLoai = row["MaTheLoai"] == DBNull.Value ? 0 : Convert.ToInt32(row["MaTheLoai"]),
                    TinhTrangSach = row["TinhTrangSach"].ToString()
                });
            }

            return list;
        }

        // Thêm sách mới
        public static bool AddBook(BookDTO book)
        {
            try
            {
                string query = @"
                    INSERT INTO Sach (TieuDe, ISBN, NamXuatBan, GiaSach, SoLuongTong, SoLuongCon, MaNXB, MaTheLoai, TinhTrangSach)
                    VALUES (@TieuDe, @ISBN, @NamXuatBan, @GiaSach, @SoLuongTong, @SoLuongCon, @MaNXB, @MaTheLoai, @TinhTrangSach)";

                int result = DataProvider.Instance.ExecuteNonQuery(query,
                    new MySqlParameter("@TieuDe", book.TieuDe),
                    new MySqlParameter("@ISBN", book.ISBN),
                    new MySqlParameter("@NamXuatBan", book.NamXuatBan),
                    new MySqlParameter("@GiaSach", book.GiaSach),
                    new MySqlParameter("@SoLuongTong", book.SoLuongTong),
                    new MySqlParameter("@SoLuongCon", book.SoLuongCon),
                    new MySqlParameter("@MaNXB", book.MaNXB),
                    new MySqlParameter("@MaTheLoai", book.MaTheLoai),
                    new MySqlParameter("@TinhTrangSach", book.TinhTrangSach ?? "Mới")
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi thêm sách: " + ex.Message);
                return false;
            }
        }

        // Cập nhật thông tin sách
        public static bool UpdateBook(BookDTO book)
        {
            try
            {
                string query = @"
                    UPDATE Sach SET
                        TieuDe = @TieuDe,
                        ISBN = @ISBN,
                        NamXuatBan = @NamXuatBan,
                        GiaSach = @GiaSach,
                        SoLuongTong = @SoLuongTong,
                        SoLuongCon = @SoLuongCon,
                        MaNXB = @MaNXB,
                        MaTheLoai = @MaTheLoai,
                        TinhTrangSach = @TinhTrangSach
                    WHERE MaSach = @MaSach";

                int result = DataProvider.Instance.ExecuteNonQuery(query,
                    new MySqlParameter("@MaSach", book.MaSach),
                    new MySqlParameter("@TieuDe", book.TieuDe),
                    new MySqlParameter("@ISBN", book.ISBN),
                    new MySqlParameter("@NamXuatBan", book.NamXuatBan),
                    new MySqlParameter("@GiaSach", book.GiaSach),
                    new MySqlParameter("@SoLuongTong", book.SoLuongTong),
                    new MySqlParameter("@SoLuongCon", book.SoLuongCon),
                    new MySqlParameter("@MaNXB", book.MaNXB),
                    new MySqlParameter("@MaTheLoai", book.MaTheLoai),
                    new MySqlParameter("@TinhTrangSach", book.TinhTrangSach ?? "Mới")
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi cập nhật sách: " + ex.Message);
                return false;
            }
        }

        // Xóa sách
        public static bool DeleteBook(int maSach)
        {
            try
            {
                string query = "DELETE FROM Sach WHERE MaSach = @MaSach";
                int result = DataProvider.Instance.ExecuteNonQuery(query,
                    new MySqlParameter("@MaSach", maSach));
                return result > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi xóa sách: " + ex.Message);
                return false;
            }
        }

        // Trí: thêm để lấy mã sách theo ID
        public static BookDTO GetBookById(int maSach)
        {
            string query = "SELECT * FROM Sach WHERE MaSach = @MaSach";
            MySqlParameter[] parameters = { new MySqlParameter("@MaSach", maSach) };

            DataTable dt = DataProvider.Instance.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                return new BookDTO
                {
                    MaSach = Convert.ToInt32(row["MaSach"]),
                    TieuDe = row["TieuDe"].ToString(),
                    //... (thêm các thuộc tính khác như TacGia, NamXuatBan... nếu bạn cần)
                    GiaSach = Convert.ToDecimal(row["GiaSach"]),
                    TinhTrangSach = row["TinhTrangSach"].ToString()
                };
            }
            return null; // Trả về null nếu không tìm thấy
        }

        public static bool UpdateBookCondition(int maSach, string? tinhTrang)
        {
            string query = "UPDATE Sach SET TinhTrangSach = @TinhTrangSach WHERE MaSach = @MaSach";
            int result = DataProvider.Instance.ExecuteNonQuery(query,
                new MySqlParameter("@TinhTrangSach", tinhTrang ?? "Mới"),
                new MySqlParameter("@MaSach", maSach));
            return result > 0;
        }
    }
}
