using Microsoft.AspNetCore.Mvc;
using QuizApplication.AppLogic;
using QuizApplication.AppLogic.Contracts;
using QuizApplication.Domain;
using QuizApplication.Web.Models;
using System.Collections.Generic;

namespace QuizApplication.Web.Controllers
{
    public class QuestionController : Controller
    {
        private readonly ILogger<QuestionController> _logger;
        private readonly IQuizService _quizService;

        public QuestionController(ILogger<QuestionController> logger, IQuizService quizService)
        {
            _logger = logger;
            _quizService = quizService;
        }
        public IActionResult Index()
        {
            IEnumerable<Category> categories = _quizService.GetAllCategories();
            return View(categories);
        }

        public IActionResult QuestionsInCategory(int id)
        {
            IEnumerable<Question> questions = _quizService.GetQuestionsInCategory(id);
            return View(questions);
        }

        public IActionResult QuestionWithAnswers(int id)
        {
            Question questionAndAnswers = _quizService.GetQuestionByIdWithAnswersAndExtra(id);
            if (questionAndAnswers == null)
            {
                return NotFound();
            }

            QuestionViewModel viewModel = new QuestionViewModel(questionAndAnswers);
            return View(viewModel);
        }


    }
}
