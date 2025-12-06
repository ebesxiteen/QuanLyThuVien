using System.Collections.Generic;
using System.Linq;
using DAO;
using DTO;

namespace BUS
{
    public class ThamSoPhatBUS
    {
        private static ThamSoPhatBUS? instance;
        public static ThamSoPhatBUS Instance => instance ??= new ThamSoPhatBUS();

        private readonly ThamSoPhatDAO dao = new();

        public List<ThamSoPhatDTO> GetAllRules()
        {
            return dao.GetAll();
        }

        public bool AddRule(ThamSoPhatDTO rule, out string message)
        {
            if (string.IsNullOrWhiteSpace(rule.LoaiTinhTrang))
            {
                message = "Loại tình trạng không được bỏ trống.";
                return false;
            }

            rule.MaThamSoPhat = dao.Add(rule);
            message = "Thêm quy định phạt thành công.";
            return rule.MaThamSoPhat > 0;
        }

        public bool UpdateRule(ThamSoPhatDTO rule, out string message)
        {
            if (rule.MaThamSoPhat <= 0)
            {
                message = "Thiếu mã tham số phạt.";
                return false;
            }

            bool result = dao.Update(rule);
            message = result ? "Cập nhật quy định phạt thành công." : "Cập nhật thất bại.";
            return result;
        }

        public bool DeleteRule(int id, out string message)
        {
            if (id <= 0)
            {
                message = "Thiếu mã quy định phạt.";
                return false;
            }

            bool result = dao.Delete(id);
            message = result ? "Xóa quy định phạt thành công." : "Không thể xóa quy định phạt.";
            return result;
        }

        public List<string> GetTearLevels()
        {
            return dao.GetAll()
                      .Where(r => r.LoaiTinhTrang == "Rách" && !string.IsNullOrWhiteSpace(r.MucDo))
                      .Select(r => r.MucDo!)
                      .Distinct()
                      .ToList();
        }
    }
}
