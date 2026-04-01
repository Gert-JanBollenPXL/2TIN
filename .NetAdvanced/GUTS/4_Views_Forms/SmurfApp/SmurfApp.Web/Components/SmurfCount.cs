using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Razor.TagHelpers;
using SmurfApp.AppLogic;

namespace SmurfApp.Web.Components
{
    public class SmurfCount : ViewComponent
    {
        private readonly ISmurfStore _store;

        public SmurfCount(ISmurfStore store)
        {
            _store = store;
        }

        public IViewComponentResult Invoke()
        {
            var count = _store.GetAll().Count();
            return View(count);
        }
    }
}
