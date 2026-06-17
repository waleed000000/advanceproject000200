using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers
{
    public class LibraryController : Controller
    {
        private readonly string _connectionString;

        public LibraryController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("HiSUP_DB")!;
        }

        public IActionResult Index()
        {
            var list = new List<Models.LibraryItem>();
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new SqlCommand("SELECT * FROM LibraryItems", conn);
                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new Models.LibraryItem
                    {
                        ItemID = (int)reader["ItemID"],
                        Title = reader["Title"].ToString()!,
                        Author = reader["Author"].ToString()!,
                        ISBN = reader["ISBN"].ToString(),
                        Category = reader["Category"].ToString(),
                        TotalCopies = (int)reader["TotalCopies"],
                        AvailableCopies = (int)reader["AvailableCopies"]
                    });
                }
            }
            return View(list);
        }

        public IActionResult Create() => View();

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Models.LibraryItem item)
        {
            if (ModelState.IsValid)
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    var cmd = new SqlCommand(
                        "INSERT INTO LibraryItems (Title, Author, ISBN, Category, TotalCopies, AvailableCopies) " +
                        "VALUES (@Title, @Author, @ISBN, @Category, @TotalCopies, @TotalCopies)", conn);
                    cmd.Parameters.AddWithValue("@Title", item.Title);
                    cmd.Parameters.AddWithValue("@Author", item.Author);
                    cmd.Parameters.AddWithValue("@ISBN", item.ISBN ?? "");
                    cmd.Parameters.AddWithValue("@Category", item.Category ?? "");
                    cmd.Parameters.AddWithValue("@TotalCopies", item.TotalCopies);
                    cmd.ExecuteNonQuery();
                }
                return RedirectToAction("Index");
            }
            return View(item);
        }
    }
}