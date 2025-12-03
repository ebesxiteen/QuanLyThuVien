using Dapper;
using DTO;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;

namespace DAO
{
    public class LoanDAO
    {
        // Thêm phiếu mượn mới bằng Dapper ORM
        public bool AddLoan(LoanDTO loan, List<LoanDetailDTO> details)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            using var transaction = connection.BeginTransaction();
            try
            {
                const string insertLoanSql = @"
                    INSERT INTO PhieuMuon (MaDocGia, MaNhanVien, NgayMuon, HanTra, TrangThai)
                    VALUES (@MaDocGia, @MaNhanVien, @NgayMuon, @HanTra, @TrangThai);
                    SELECT LAST_INSERT_ID();";

                int maPhieuMuon = connection.ExecuteScalar<int>(insertLoanSql, loan, transaction);

                const string insertDetailSql = @"
                    INSERT INTO ChiTietMuon (MaPhieuMuon, MaSach, SoLuong)
                    VALUES (@MaPhieuMuon, @MaSach, @SoLuong);";

                var detailParams = details.Select(d => new
                {
                    MaPhieuMuon = maPhieuMuon,
                    d.MaSach,
                    d.SoLuong
                });

                connection.Execute(insertDetailSql, detailParams, transaction);

                transaction.Commit();
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi thêm phiếu mượn: " + ex.Message);
                transaction.Rollback();
                return false;
            }
        }

        // Lấy danh sách tất cả phiếu mượn
        public List<LoanDTO> GetAllLoans()
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = "SELECT * FROM PhieuMuon ORDER BY NgayMuon DESC";
            return connection.Query<LoanDTO>(query).ToList();
        }

        public List<LoanDTO> GetUnreturnedLoans()
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = @"
                SELECT MaPhieuMuon, MaDocGia, MaNhanVien, NgayMuon, HanTra, TrangThai
                FROM phieumuon
                WHERE TrangThai != 'Đã trả';";

            return connection.Query<LoanDTO>(query).ToList();
        }

        public LoanDTO? GetLoanById(int maPhieuMuon)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = "SELECT * FROM PhieuMuon WHERE MaPhieuMuon = @MaPhieuMuon";
            return connection.QuerySingleOrDefault<LoanDTO>(query, new { MaPhieuMuon = maPhieuMuon });
        }

        public void UpdateLoanStatus(int maPhieuMuon, string trangThai)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = "UPDATE PhieuMuon SET TrangThai = @TrangThai WHERE MaPhieuMuon = @MaPhieuMuon";
            connection.Execute(query, new { TrangThai = trangThai, MaPhieuMuon = maPhieuMuon });
        }

        public List<LoanDTO> SearchLoans(string keyword)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = @"
            SELECT DISTINCT pm.*
            FROM phieumuon pm
            JOIN docgia dg ON pm.MaDocGia = dg.MaDocGia
            JOIN chitietmuon ctm ON pm.MaPhieuMuon = ctm.MaPhieuMuon
            JOIN sach s ON ctm.MaSach = s.MaSach
            WHERE
            CAST(pm.MaPhieuMuon AS CHAR) LIKE @kw OR
            pm.TrangThai LIKE @kw OR
            dg.HoTen LIKE @kw OR
            s.TieuDe LIKE @kw;";

            return connection.Query<LoanDTO>(query, new { kw = "%" + keyword + "%" }).ToList();
        }

        public bool DeleteLoan(int maPhieuMuon)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            using var transaction = connection.BeginTransaction();
            try
            {
                const string checkQuery = "SELECT TrangThai FROM PhieuMuon WHERE MaPhieuMuon = @MaPhieuMuon";
                string? trangThai = connection.ExecuteScalar<string?>(checkQuery, new { MaPhieuMuon = maPhieuMuon }, transaction);

                if (trangThai == null || !trangThai.Equals("Đang mượn", StringComparison.OrdinalIgnoreCase))
                {
                    transaction.Rollback();
                    return false;
                }

                const string deleteDetailQuery = "DELETE FROM ChiTietMuon WHERE MaPhieuMuon = @MaPhieuMuon";
                const string deleteLoanQuery = "DELETE FROM PhieuMuon WHERE MaPhieuMuon = @MaPhieuMuon";

                connection.Execute(deleteDetailQuery, new { MaPhieuMuon = maPhieuMuon }, transaction);
                int rowsAffected = connection.Execute(deleteLoanQuery, new { MaPhieuMuon = maPhieuMuon }, transaction);

                transaction.Commit();
                return rowsAffected > 0;
            }
            catch (MySqlException ex)
            {
                Console.WriteLine("❌ Lỗi khi xóa phiếu mượn: " + ex.Message);
                transaction.Rollback();
                return false;
            }
        }

        public List<LoanDTO> SearchUnreturnedLoans(string keyword)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = @"
                    SELECT DISTINCT pm.*
                    FROM phieumuon pm
                    LEFT JOIN docgia dg ON pm.MaDocGia = dg.MaDocGia
                    LEFT JOIN chitietmuon ctm ON pm.MaPhieuMuon = ctm.MaPhieuMuon
                    LEFT JOIN sach s ON ctm.MaSach = s.MaSach
                    WHERE
                    pm.TrangThai != 'Đã trả' AND
                    (
                        CAST(pm.MaPhieuMuon AS CHAR) LIKE @kw OR
                        dg.HoTen LIKE @kw OR
                        s.TieuDe LIKE @kw
                    );";

            return connection.Query<LoanDTO>(query, new { kw = "%" + keyword + "%" }).ToList();
        }

        public bool ExtendDueDate(int maPhieuMuon, DateTime newDueDate)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = @"
                UPDATE PhieuMuon
                SET HanTra = @HanTra, TrangThai = 'Đang mượn'
                WHERE MaPhieuMuon = @MaPhieuMuon";

            int result = connection.Execute(query, new { HanTra = newDueDate, MaPhieuMuon = maPhieuMuon });
            return result > 0;
        }
    }
}
