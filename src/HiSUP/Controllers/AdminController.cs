using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers
{
    [Authorize(Roles = "Admin")]
    public class AdminController : Controller
    {
        private readonly string _connectionString;

        public AdminController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("HiSUP_DB")!;
        }

        public IActionResult Index()
        {
            var stats = new Models.DashboardStats();

            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();

                stats.TotalStudents = (int)new SqlCommand("SELECT COUNT(*) FROM Students", conn).ExecuteScalar();
                stats.TotalFaculty = (int)new SqlCommand("SELECT COUNT(*) FROM Faculty", conn).ExecuteScalar();
                stats.TotalCourses = (int)new SqlCommand("SELECT COUNT(*) FROM Courses", conn).ExecuteScalar();
                stats.TotalDepartments = (int)new SqlCommand("SELECT COUNT(*) FROM Departments", conn).ExecuteScalar();
                stats.TotalLibraryItems = (int)new SqlCommand("SELECT COUNT(*) FROM LibraryItems", conn).ExecuteScalar();

                var feeResult = new SqlCommand("SELECT ISNULL(SUM(Amount),0) FROM FeePayments", conn).ExecuteScalar();
                stats.TotalFeeCollected = feeResult == DBNull.Value ? 0 : (decimal)feeResult;
            }

            return View(stats);
        }
    }
}