using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models
{
    public class Student
    {
        public int StudentID { get; set; }

        [Required]
        [Display(Name = "First Name")]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [Display(Name = "Last Name")]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string CNIC { get; set; } = string.Empty;

        public string? Phone { get; set; }

        [Display(Name = "Department")]
        public int DepartmentID { get; set; }

        [Display(Name = "Program")]
        public int ProgramID { get; set; }

        public int Semester { get; set; } = 1;

        public decimal CGPA { get; set; } = 0;

        public string Status { get; set; } = "Active";

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}