using Dapper;
using DTO;
using System.Collections.Generic;
using System.Linq;

namespace DAO
{
    public class ThamSoPhatDAO
    {
        public List<ThamSoPhatDTO> GetAll()
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = "SELECT * FROM ThamSoPhat ORDER BY LoaiTinhTrang, MaThamSoPhat";
            return connection.Query<ThamSoPhatDTO>(query).ToList();
        }

        public int Add(ThamSoPhatDTO rule)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = @"INSERT INTO ThamSoPhat (LoaiTinhTrang, MucDo, MoTa, SoTien)
                                   VALUES (@LoaiTinhTrang, @MucDo, @MoTa, @SoTien);
                                   SELECT LAST_INSERT_ID();";
            return connection.ExecuteScalar<int>(query, rule);
        }

        public bool Update(ThamSoPhatDTO rule)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = @"UPDATE ThamSoPhat
                                   SET LoaiTinhTrang = @LoaiTinhTrang,
                                       MucDo = @MucDo,
                                       MoTa = @MoTa,
                                       SoTien = @SoTien
                                   WHERE MaThamSoPhat = @MaThamSoPhat";
            return connection.Execute(query, rule) > 0;
        }

        public bool Delete(int id)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = "DELETE FROM ThamSoPhat WHERE MaThamSoPhat = @id";
            return connection.Execute(query, new { id }) > 0;
        }
    }
}
