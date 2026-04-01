using System.Diagnostics;
using System.Text;

namespace RomanNumberConverterApp.Ui.Models;

public class RomanNumberConverter : IRomanNumberConverter
{
    public string Convert(int number)
    {
        if (number <= 0 || number > 3999)
            throw new ArgumentException(nameof(number), "1-3999");

        var romanNumerals = new (int value, string symbol)[]
        {
        (1000, "M"),
        (900, "CM"),
        (500, "D"),
        (400, "CD"),
        (100, "C"),
        (90, "XC"),
        (50, "L"),
        (40, "XL"),
        (10, "X"),
        (9, "IX"),
        (5, "V"),
        (4, "IV"),
        (1, "I")
        };

        var result = new StringBuilder();

        foreach (var (value, symbol) in romanNumerals)
        {
            while (number >= value)
            {
                result.Append(symbol);
                number -= value;
            }
        }

        return result.ToString();
    }


}