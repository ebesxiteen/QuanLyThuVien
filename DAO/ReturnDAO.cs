using Dapper;
using DTO;
using System.Collections.Generic;
using System.Linq;

namespace DAO
{
    public class ReturnDAO
    {
        public int AddReturn(ReturnDTO ret, IEnumerable<LoanDetailDTO> loanDetails)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            using var transaction = connection.BeginTransaction();

            const string insertReturnSql = @"
                INSERT INTO PhieuTra (MaPhieuMuon, NgayTra, TinhTrangSach, TienPhat)
                VALUES (@MaPhieuMuon, @NgayTra, @TinhTrangSach, @TienPhat);
                SELECT LAST_INSERT_ID();";

            int maPhieuTra = connection.ExecuteScalar<int>(insertReturnSql, ret, transaction);

            const string insertDetailSql = @"
                INSERT INTO ChiTietTra (MaPhieuTra, MaSach, TinhTrangTra, TienPhat)
                VALUES (@MaPhieuTra, @MaSach, @TinhTrangTra, @TienPhat)
                ON DUPLICATE KEY UPDATE
                    TinhTrangTra = VALUES(TinhTrangTra),
                    TienPhat = VALUES(TienPhat);";

            var detailParams = loanDetails.Select(d => new
            {
                MaPhieuTra = maPhieuTra,
                d.MaSach,
                TinhTrangTra = ret.TinhTrangSach,
                TienPhat = 0
            });

            connection.Execute(insertDetailSql, detailParams, transaction);

            const string updateLoanSql = "UPDATE PhieuMuon SET TrangThai = 'Đã trả' WHERE MaPhieuMuon = @MaPhieuMuon";
            connection.Execute(updateLoanSql, new { ret.MaPhieuMuon }, transaction);

            transaction.Commit();
            return maPhieuTra;
        }

        public List<ReturnDTO> GetAllReturns()
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = "SELECT * FROM phieutra";
            return connection.Query<ReturnDTO>(query).ToList();
        }
        public List<ReturnDTO> SearchReturns(string keyword)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = @"
                SELECT * FROM phieutra
                WHERE MaPhieuTra LIKE @kw
                OR MaPhieuMuon LIKE @kw
                OR TinhTrangSach LIKE @kw";

            return connection.Query<ReturnDTO>(query, new { kw = "%" + keyword + "%" }).ToList();
        }

    }
}
