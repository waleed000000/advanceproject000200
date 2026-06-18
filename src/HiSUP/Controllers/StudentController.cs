using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using Microsoft.AspNetCore.Authorization;

namespace HiSUP.Controllers
{
    [Authorize(Roles = "Admin,Faculty")]
    public class StudentController : Controller
    {
        private readonly string _connectionString;

        public StudentController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("HiSUP_DB")!;
        }

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
                        LastName  = reader["LastName"].ToString()!,
                        Email     = reader["Email"].ToString()!,
                        CNIC      = reader["CNIC"].ToString()!,
                        Phone     = reader["Phone"].ToString(),
                        Semester  = (int)reader["Semester"],
                        CGPA      = (decimal)reader["CGPA"],
                        Status    = reader["Status"].ToString()!
                    });
                }
            }
            return View(students);
        }

        public IActionResult Create()
        {
            return View();
        }

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
                    cmd.Parameters.AddWithValue("@LastName",  student.LastName);
                    cmd.Parameters.AddWithValue("@Email",     student.Email);
                    cmd.Parameters.AddWithValue("@CNIC",      student.CNIC);
                    cmd.Parameters.AddWithValue("@Phone",     student.Phone ?? "");
                    cmd.Parameters.AddWithValue("@DeptID",    student.DepartmentID);
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
                        LastName  = reader["LastName"].ToString()!,
                        Email     = reader["Email"].ToString()!,
                        CNIC      = "",
                        Semester  = (int)reader["Semester"],
                        CGPA      = (decimal)reader["CGPA"]
                    };
                }
            }
            if (student == null) return NotFound();
            return View(student);
        }

        public IActionResult Edit(int id)
        {
            Models.Student? student = null;
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand("SELECT * FROM Students WHERE StudentID = @id", conn);
                cmd.Parameters.AddWithValue("@id", id);
                var reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    student = new Models.Student
                    {
                        StudentID    = (int)reader["StudentID"],
                        FirstName    = reader["FirstName"].ToString()!,
                        LastName     = reader["LastName"].ToString()!,
                        Email        = reader["Email"].ToString()!,
                        CNIC         = reader["CNIC"].ToString()!,
                        Phone        = reader["Phone"].ToString(),
                        DepartmentID = (int)reader["DepartmentID"],
                        ProgramID    = (int)reader["ProgramID"],
                        Semester     = (int)reader["Semester"],
                        CGPA         = (decimal)reader["CGPA"],
                        Status       = reader["Status"].ToString()!
                    };
                }
            }
            if (student == null) return NotFound();
            return View(student);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(Models.Student student)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(
                    "UPDATE Students SET FirstName=@FirstName, LastName=@LastName, " +
                    "Email=@Email, Phone=@Phone, Semester=@Semester, Status=@Status " +
                    "WHERE StudentID=@StudentID", conn);
                cmd.Parameters.AddWithValue("@FirstName",  student.FirstName);
                cmd.Parameters.AddWithValue("@LastName",   student.LastName);
                cmd.Parameters.AddWithValue("@Email",      student.Email);
                cmd.Parameters.AddWithValue("@Phone",      student.Phone ?? "");
                cmd.Parameters.AddWithValue("@Semester",   student.Semester);
                cmd.Parameters.AddWithValue("@Status",     student.Status);
                cmd.Parameters.AddWithValue("@StudentID",  student.StudentID);
                cmd.ExecuteNonQuery();
            }
            return RedirectToAction("Index");
        }

       public IActionResult Delete(int id)
{
    using (var conn = new SqlConnection(_connectionString))
    {
        conn.Open();
        // Pehle related data delete karo
        new SqlCommand("DELETE FROM FeePayments WHERE StudentID = @id", conn)
            { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
        new SqlCommand("DELETE FROM Enrollments WHERE StudentID = @id", conn)
            { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
        new SqlCommand("DELETE FROM AttendanceRecords WHERE StudentID = @id", conn)
            { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
        new SqlCommand("DELETE FROM LibraryIssues WHERE StudentID = @id", conn)
            { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
        new SqlCommand("DELETE FROM Results WHERE StudentID = @id", conn)
            { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
        new SqlCommand("DELETE FROM HostelAllotments WHERE StudentID = @id", conn)
            { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
        // Ab student delete karo
        new SqlCommand("DELETE FROM Students WHERE StudentID = @id", conn)
            { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
    }
    return RedirectToAction("Index");
}    }
}