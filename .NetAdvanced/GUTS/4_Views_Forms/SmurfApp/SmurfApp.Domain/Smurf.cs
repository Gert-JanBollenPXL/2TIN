using System.ComponentModel.DataAnnotations;

namespace SmurfApp.Domain;

public class Smurf
{
    public Guid Id { get; set; }

    [Required(ErrorMessage = "Name is required")]
    [MaxLength(50, ErrorMessage = "Name cannot exceed 50 characters.")]
    public string Name { get; set; }

    [Required(ErrorMessage = "Age is required.")]
    [Range(1, 1000, ErrorMessage = "Age must be between 1 and 1000.")]
    public int Age { get; set; }

    [Required(ErrorMessage = "Image URL is required.")]
    [Url(ErrorMessage = "Invalid URL format.")]
    [Display(Name = "Image URL")]
    public string ImageUrl  { get; set; }

    [Required(ErrorMessage = "Category is required.")]
    public Category Category { get; set; }

    public Smurf()
    {
        Id = Guid.NewGuid();
        Name = string.Empty;
        Age = 100;
        ImageUrl = string.Empty;
        Category = Category.Skilled;
    }
}