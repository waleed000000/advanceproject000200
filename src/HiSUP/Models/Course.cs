using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models
{
    public class Course
    {
        public int CourseID { get; set; }

        [Required]
        [Display(Name = "Course Name")]
        public string CourseName { get; set; } = string.Empty;

        [Required]
        [Display(Name = "Course Code")]
        public string CourseCode { get; set; } = string.Empty;

        [Range(1, 4)]
        [Display(Name = "Credit Hours")]
        public int CreditHours { get; set; }

        [Display(Name = "Department")]
        public int DepartmentID { get; set; }

        public string? DeptName { get; set; } // for display only
    }
}