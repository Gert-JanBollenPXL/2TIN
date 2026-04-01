using System.ComponentModel.DataAnnotations;

namespace QuizApplication.Domain
{
    public class Answer
    {
        public int Id { get; set; }

        /* Please leave this MaxLength attribute on the AnswerText property, 
         * the GUTS tests will fail if removed */
        [MaxLength(100)]
        public string AnswerText { get; set; }
        public int QuestionId { get; set; }
        public bool IsCorrect { get; set; }

        public Answer() 
        {
            AnswerText = string.Empty;
        }
    }
}
