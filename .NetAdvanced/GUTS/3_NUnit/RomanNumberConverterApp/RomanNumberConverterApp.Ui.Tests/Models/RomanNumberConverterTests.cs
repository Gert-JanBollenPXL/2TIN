using RomanNumberConverterApp.Ui.Models;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace RomanNumberConverterApp.Ui.Tests.Models
{
    public class RomanNumberConverterTests
    {
        private RomanNumberConverter _converter = null;

        [SetUp] public void SetUp() 
        {
            _converter = new RomanNumberConverter();
        }

        [TestCase(0)]
        [TestCase(4000)]
        public void Convert_ValueIsNotBetweenOneAnd3999_ShouldThrowArgumentException(int number)
        {
            Assert.That(() => _converter.Convert(number), Throws.ArgumentException.With.Message.Contains("1-3999"));
        }

        [TestCase(1, "I")]
        [TestCase(4, "IV")]
        [TestCase(9, "IX")]
        [TestCase(58, "LVIII")]
        [TestCase(1994, "MCMXCIV")]
        [TestCase(3999, "MMMCMXCIX")]
        public void Convert_ValidValue_ShouldReturnRomanNumberEquivalent(int number, string expected)
        {
            var result = _converter.Convert(number);

            Assert.That(result, Is.EqualTo(expected));
        }
    }
}