using System.Data;
using System.Diagnostics;
using DotNetEnv;
using MySql.Data.MySqlClient;

namespace DAO
{
    public sealed class DataProvider
    {
        private static readonly Lazy<DataProvider> instance =
            new Lazy<DataProvider>(() => new DataProvider());

        public static DataProvider Instance => instance.Value;

        private readonly string connectionSTR;

        public string ConnectionString => connectionSTR;

        private DataProvider()
        {
            try
            {
                // Tìm file .env tại solution gốc
                var solutionDir = Directory.GetParent(AppDomain.CurrentDomain.BaseDirectory)!
                                        .Parent!.Parent!.Parent!.Parent!.FullName;
                var envPath = Path.Combine(solutionDir, ".env");
                Debug.WriteLine($"Loading .env file from: {envPath}");

                Env.Load(envPath);

                string server = Env.GetString("DB_SERVER") ?? "localhost";
                string port = Env.GetString("DB_PORT") ?? "3306";
                string database = Env.GetString("DB_NAME") ?? "QuanLyThuVien";
                string uid = Env.GetString("DB_USER") ?? "root";
                string pwd = Env.GetString("DB_PASSWORD") ?? "vinh";

                connectionSTR = $"server={server};port={port};database={database};uid={uid};pwd={pwd};";
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[DataProvider Init Error] {ex.Message}");
                throw;
            }
        }

        public bool TestConnection()
        {
            try
            {
                using var connection = new MySqlConnection(connectionSTR);
                connection.Open();
                return true;
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[TestConnection] {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Tạo kết nối mới để dùng với ORM (Dapper/EF,...). Caller chịu trách nhiệm dispose.
        /// </summary>
        public MySqlConnection CreateConnection()
        {
            var connection = new MySqlConnection(connectionSTR);
            connection.Open();
            return connection;
        }

        /// <summary>
        /// Thực thi truy vấn SELECT và trả về DataTable.
        /// <para>Ví dụ 1: Không có tham số</para>
        /// <code>
        /// DataTable dt = DataProvider.Instance.ExecuteQuery("SELECT * FROM Sach");
        /// </code>
        /// <para>Ví dụ 2: có tham số</para>
        /// <code>
        /// string sql = "SELECT * FROM DocGia WHERE Email = @Email";
        /// var param = new MySqlParameter("@Email", "abc@example.com");
        /// </code>
        /// </summary>
        /// <returns>DataTable chứa kết quả truy vấn</returns>
        public DataTable ExecuteQuery(string query, params MySqlParameter[] parameters)
        {
            var data = new DataTable();

            using var connection = new MySqlConnection(connectionSTR);
            connection.Open();

            using var command = new MySqlCommand(query, connection);
            if (parameters?.Length > 0)
                command.Parameters.AddRange(parameters);

            using var adapter = new MySqlDataAdapter(command);
            adapter.Fill(data);

            return data;
        }

        /// <summary>
        /// Thực thi các truy vấn INSERT, UPDATE, DELETE. Trả về số dòng bị ảnh hưởng.
        /// </summary>
        /// <param name="query"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public int ExecuteNonQuery(string query, params MySqlParameter[] parameters)
        {
            using var connection = new MySqlConnection(connectionSTR);
            connection.Open();

            using var command = new MySqlCommand(query, connection);
            if (parameters?.Length > 0)
                command.Parameters.AddRange(parameters);

            return command.ExecuteNonQuery();
        }

        /// <summary>
        /// Thực thi truy vấn trả về một giá trị đơn (cột đầu tiên của hàng đầu tiên).
        /// </summary>
        /// <param name="query"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public object? ExecuteScalar(string query, params MySqlParameter[] parameters)
        {
            using var connection = new MySqlConnection(connectionSTR);
            connection.Open();

            using var command = new MySqlCommand(query, connection);
            if (parameters?.Length > 0)
                command.Parameters.AddRange(parameters);

            return command.ExecuteScalar();
        }
    }
}
