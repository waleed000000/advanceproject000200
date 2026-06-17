using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models
{
    public class LibraryItem
    {
        public int ItemID { get; set; }

        [Required]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Author { get; set; } = string.Empty;

        public string? ISBN { get; set; }
        public string? Category { get; set; }

        [Display(Name = "Total Copies")]
        public int TotalCopies { get; set; } = 1;

        [Display(Name = "Available Copies")]
        public int AvailableCopies { get; set; } = 1;
    }
}