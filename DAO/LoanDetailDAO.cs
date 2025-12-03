using Dapper;
using DTO;
using System.Collections.Generic;
using System.Linq;

namespace DAO
{
    public class LoanDetailDAO
    {
        private static LoanDetailDAO instance;
        public static LoanDetailDAO Instance
        {
            get
            {
                if (instance == null)
                    instance = new LoanDetailDAO();
                return instance;
            }
        }

        private LoanDetailDAO() { }

        public List<LoanDetailDTO> GetLoanDetailsByLoanId(int maPhieuMuon)
        {
            using var connection = DataProvider.Instance.CreateConnection();
            const string query = "SELECT * FROM ChiTietMuon WHERE MaPhieuMuon = @MaPhieuMuon";
            return connection.Query<LoanDetailDTO>(query, new { MaPhieuMuon = maPhieuMuon }).ToList();
        }
    }
}
