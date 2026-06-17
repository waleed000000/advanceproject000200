using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models
{
    public class FeePayment
    {
        public int PaymentID { get; set; }

        [Display(Name = "Student ID")]
        public int StudentID { get; set; }

        [Required]
        public decimal Amount { get; set; }

        [Display(Name = "Payment Method")]
        public string PaymentMethod { get; set; } = "Cash";

        public DateTime PaymentDate { get; set; } = DateTime.Now;
        public string Status { get; set; } = "Paid";

        public string? StudentName { get; set; } // for display
    }
}