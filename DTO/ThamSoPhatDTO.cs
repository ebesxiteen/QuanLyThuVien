namespace DTO
{
    public class ThamSoPhatDTO
    {
        public int MaThamSoPhat { get; set; }
        public string LoaiTinhTrang { get; set; } = string.Empty;
        public string? MucDo { get; set; }
        public string? MoTa { get; set; }
        public decimal SoTien { get; set; }
    }
}
