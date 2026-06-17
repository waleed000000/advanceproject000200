using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace HiSUP.Controllers
{
    public class FeeController : Controller
    {
        private readonly string _connectionString;

        public FeeController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("HiSUP_DB")!;
        }

        public IActionResult Index()
        {
            var list = new List<Models.FeePayment>();
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(
                    "SELECT FP.*, S.FirstName, S.LastName FROM FeePayments FP " +
                    "JOIN Students S ON FP.StudentID = S.StudentID ORDER BY FP.PaymentDate DESC", conn);
                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new Models.FeePayment
                    {
                        PaymentID = (int)reader["PaymentID"],
                        StudentID = (int)reader["StudentID"],
                        Amount = (decimal)reader["Amount"],
                        PaymentMethod = reader["PaymentMethod"].ToString()!,
                        PaymentDate = (DateTime)reader["PaymentDate"],
                        Status = reader["Status"].ToString()!,
                        StudentName = reader["FirstName"] + " " + reader["LastName"]
                    });
                }
            }
            return View(list);
        }

        public IActionResult Create() => View();

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Models.FeePayment payment)
        {
            if (ModelState.IsValid)
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    var cmd = new SqlCommand("ProcessFeePayment", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@StudentID", payment.StudentID);
                    cmd.Parameters.AddWithValue("@Amount", payment.Amount);
                    cmd.Parameters.AddWithValue("@PaymentMethod", payment.PaymentMethod);
                    var outParam = new SqlParameter("@PaymentID", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outParam);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            return View(payment);
        }
    }
}