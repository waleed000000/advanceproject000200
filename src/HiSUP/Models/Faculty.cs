using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models
{
    public class Faculty
    {
        public int FacultyID { get; set; }

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

        public string? Designation { get; set; }

        public string Status { get; set; } = "Active";
    }
}