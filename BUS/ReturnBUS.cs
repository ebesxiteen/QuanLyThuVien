using System;
using System.Collections.Generic;
using System.Linq;
using DAO;
using DTO;

namespace BUS
{
    public class ReturnBUS
    {
        private readonly ReturnDAO returnDAO = new();
        private readonly LoanDAO loanDAO = new();
        private readonly FineBUS fineBUS = new();

        public List<ReturnDTO> GetAllReturns()
        {
            return returnDAO.GetAllReturns();
        }

        public bool AddReturn(ReturnDTO ret, out string message)
        {
            if (ret.MaPhieuMuon <= 0)
            {
                message = "Vui lòng chọn phiếu mượn hợp lệ!";
                return false;
            }

            if (ret.NgayTra == DateTime.MinValue)
            {
                message = "Vui lòng chọn ngày trả hợp lệ!";
                return false;
            }

            var loanDetails = LoanDetailDAO.Instance.GetLoanDetailsByLoanId(ret.MaPhieuMuon);

            int result = returnDAO.AddReturn(ret, loanDetails);
            if (result <= 0)
            {
                message = "Lỗi khi thêm phiếu trả!";
                return false;
            }

            var loan = loanDAO.GetLoanById(ret.MaPhieuMuon);
            if (loan == null)
            {
                message = "Không tìm thấy phiếu mượn tương ứng!";
                return false;
            }

            bool hasFine = false;
            decimal soTien = 0;
            string lyDo = "";

            if (ret.NgayTra > loan.HanTra)
            {
                int soNgayTre = (ret.NgayTra.Date - loan.HanTra.Date).Days;
                if (soNgayTre > 0)
                {
                    soTien += soNgayTre * 5000;
                    lyDo += $"Trả trễ {soNgayTre} ngày. ";
                    hasFine = true;
                }
            }

            if (!string.IsNullOrEmpty(ret.TinhTrangSach) && ret.TinhTrangSach != "Tốt")
            {
                soTien += 10000;
                lyDo += "Sách bị hư hỏng. ";
                hasFine = true;
            }

            if (hasFine)
            {
                var fine = new FineDTO
                {
                    MaPhieuTra = result,
                    LyDo = lyDo.Trim(),
                    SoTien = soTien,
                    NgayLap = DateTime.Now
                };
                fineBUS.AddFine(fine);

                message = $"Trả sách thành công, bị phạt {soTien:N0}đ ({lyDo.Trim()})";
            }
            else
            {
                message = "Trả sách thành công, không có tiền phạt.";
            }

            foreach (var detail in loanDetails)
            {
                BookBUS.UpdateBookCondition(detail.MaSach, ret.TinhTrangSach);
            }

            return true;
        }
        public List<ReturnDTO> SearchReturns(string keyword)
        {
            return returnDAO.SearchReturns(keyword);
        }
    }
}
