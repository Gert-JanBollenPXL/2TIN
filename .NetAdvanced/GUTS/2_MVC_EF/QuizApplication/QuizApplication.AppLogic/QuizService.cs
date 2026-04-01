using System;
using System.Collections.Generic;
using System.Linq;
using QuizApplication.AppLogic.Contracts;
using QuizApplication.Domain;

namespace QuizApplication.AppLogic
{
    internal class QuizService : IQuizService
    {
        private readonly ICategoryRepository _categoryRepository;
        private readonly IQuestionRepository _questionRepository;

        public QuizService(ICategoryRepository categoryRepository, IQuestionRepository questionRepository)
        {
            _categoryRepository = categoryRepository;
            _questionRepository = questionRepository;
        }

        public IReadOnlyList<Category> GetAllCategories()
        {
            return _categoryRepository.GetAll();
        }

        public Question GetQuestionByIdWithAnswersAndExtra(int id)
        {
            Question question = _questionRepository.GetByIdWithAnswers(id);

            bool hasCorrect = question.Answers.Any(a => a.IsCorrect);
            Answer extraAnswer = new Answer
            {
                AnswerText = "None of the answers is correct.",
                IsCorrect = !hasCorrect
            };
            question.Answers.Add(extraAnswer);
            return question;
        }

        public IReadOnlyList<Question> GetQuestionsInCategory(int id)
        {
            return _questionRepository.GetByCategoryId(id);
        }
    }
}
