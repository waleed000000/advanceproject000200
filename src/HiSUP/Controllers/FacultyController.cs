using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Authorization;
namespace HiSUP.Controllers
{
    [Authorize(Roles = "Admin,Faculty")]
    
    public class FacultyController : Controller
    {
        private readonly string _connectionString;

        public FacultyController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("HiSUP_DB")!;
        }

        public IActionResult Index()
        {
            var list = new List<Models.Faculty>();
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(
                    "SELECT F.*, D.DeptName FROM Faculty F JOIN Departments D ON F.DepartmentID = D.DepartmentID", conn);
                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new Models.Faculty
                    {
                        FacultyID = (int)reader["FacultyID"],
                        FirstName = reader["FirstName"].ToString()!,
                        LastName = reader["LastName"].ToString()!,
                        Email = reader["Email"].ToString()!,
                        CNIC = reader["CNIC"].ToString()!,
                        Phone = reader["Phone"].ToString(),
                        Designation = reader["Designation"].ToString(),
                        Status = reader["Status"].ToString()!
                    });
                }
            }
            return View(list);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Models.Faculty faculty)
        {
            if (ModelState.IsValid)
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    var cmd = new SqlCommand(
                        "INSERT INTO Faculty (FirstName, LastName, Email, CNIC, Phone, DepartmentID, Designation) " +
                        "VALUES (@FirstName, @LastName, @Email, @CNIC, @Phone, @DeptID, @Designation)", conn);
                    cmd.Parameters.AddWithValue("@FirstName", faculty.FirstName);
                    cmd.Parameters.AddWithValue("@LastName", faculty.LastName);
                    cmd.Parameters.AddWithValue("@Email", faculty.Email);
                    cmd.Parameters.AddWithValue("@CNIC", faculty.CNIC);
                    cmd.Parameters.AddWithValue("@Phone", faculty.Phone ?? "");
                    cmd.Parameters.AddWithValue("@DeptID", faculty.DepartmentID);
                    cmd.Parameters.AddWithValue("@Designation", faculty.Designation ?? "");
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            return View(faculty);
        }
    }
}