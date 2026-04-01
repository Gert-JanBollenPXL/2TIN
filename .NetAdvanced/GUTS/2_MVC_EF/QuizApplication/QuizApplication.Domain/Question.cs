using System.ComponentModel.DataAnnotations;

namespace QuizApplication.Domain
{
    public class Question
    {
        public int Id { get; set; }

        /* Please leave this MaxLength attribute on the QuestionString property, 
         * the GUTS tests will fail if removed */
        [MaxLength(100)]
        public string QuestionString { get; set; }

        public int CategoryId { get; set; }
        public IList<Answer> Answers { get; set; }

        public Question()
        {
            QuestionString = string.Empty;
            Answers = new List<Answer>();
        }
    }
}
