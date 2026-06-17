using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Authorization;
namespace HiSUP.Controllers
{
    [Authorize(Roles = "Admin,Faculty")]
   
    public class CourseController : Controller
    {
        private readonly string _connectionString;

        public CourseController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("HiSUP_DB")!;
        }

        public IActionResult Index()
        {
            var list = new List<Models.Course>();
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(
                    "SELECT C.*, D.DeptName FROM Courses C JOIN Departments D ON C.DepartmentID = D.DepartmentID", conn);
                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new Models.Course
                    {
                        CourseID = (int)reader["CourseID"],
                        CourseName = reader["CourseName"].ToString()!,
                        CourseCode = reader["CourseCode"].ToString()!,
                        CreditHours = (int)reader["CreditHours"],
                        DepartmentID = (int)reader["DepartmentID"],
                        DeptName = reader["DeptName"].ToString()
                    });
                }
            }
            return View(list);
        }

        public IActionResult Create() => View();

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Models.Course course)
        {
            if (ModelState.IsValid)
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    var cmd = new SqlCommand(
                        "INSERT INTO Courses (CourseName, CourseCode, CreditHours, DepartmentID) " +
                        "VALUES (@CourseName, @CourseCode, @CreditHours, @DeptID)", conn);
                    cmd.Parameters.AddWithValue("@CourseName", course.CourseName);
                    cmd.Parameters.AddWithValue("@CourseCode", course.CourseCode);
                    cmd.Parameters.AddWithValue("@CreditHours", course.CreditHours);
                    cmd.Parameters.AddWithValue("@DeptID", course.DepartmentID);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            return View(course);
        }
    }
}