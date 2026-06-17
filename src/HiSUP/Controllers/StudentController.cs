using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace HiSUP.Controllers
{
    public class StudentController : Controller
    {
        private readonly string _connectionString;

        public StudentController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("HiSUP_DB")!;
        }

        // GET: Student/Index
        public IActionResult Index()
        {
            var students = new List<Models.Student>();
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand("SELECT * FROM Students", conn);
                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    students.Add(new Models.Student
                    {
                        StudentID = (int)reader["StudentID"],
                        FirstName = reader["FirstName"].ToString()!,
                        LastName = reader["LastName"].ToString()!,
                        Email = reader["Email"].ToString()!,
                        CNIC = reader["CNIC"].ToString()!,
                        Phone = reader["Phone"].ToString(),
                        Semester = (int)reader["Semester"],
                        CGPA = (decimal)reader["CGPA"],
                        Status = reader["Status"].ToString()!
                    });
                }
            }
            return View(students);
        }

        // GET: Student/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Student/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Models.Student student)
        {
            if (ModelState.IsValid)
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    var cmd = new SqlCommand("RegisterStudent", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FirstName", student.FirstName);
                    cmd.Parameters.AddWithValue("@LastName", student.LastName);
                    cmd.Parameters.AddWithValue("@Email", student.Email);
                    cmd.Parameters.AddWithValue("@CNIC", student.CNIC);
                    cmd.Parameters.AddWithValue("@Phone", student.Phone ?? "");
                    cmd.Parameters.AddWithValue("@DeptID", student.DepartmentID);
                    cmd.Parameters.AddWithValue("@ProgramID", student.ProgramID);
                    var outParam = new SqlParameter("@NewStudentID", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outParam);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            return View(student);
        }

        // GET: Student/Details/5
        public IActionResult Details(int id)
        {
            Models.Student? student = null;
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand("GetStudentReport", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", id);
                var reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    student = new Models.Student
                    {
                        StudentID = (int)reader["StudentID"],
                        FirstName = reader["FirstName"].ToString()!,
                        LastName = reader["LastName"].ToString()!,
                        Email = reader["Email"].ToString()!,
                        CNIC = "",
                        Semester = (int)reader["Semester"],
                        CGPA = (decimal)reader["CGPA"]
                    };
                }
            }
            if (student == null) return NotFound();
            return View(student);
        }
    }
}