using Microsoft.AspNetCore.Mvc;
using SmurfApp.AppLogic;
using SmurfApp.Domain;
using SmurfApp.Web.Models;

namespace SmurfApp.Web.Controllers;

public class SmurfController : Controller
{
    private readonly ILogger _logger;
    private readonly ISmurfStore _store;
    public SmurfController(ILogger<SmurfController> logger, ISmurfStore smurfStore)
    {
        _logger = logger;
        _store = smurfStore;
    }

    [HttpGet]
    public IActionResult AddOrUpdate(Guid? id)
    {
        AddOrUpdateSmurfViewModel viewModel = new AddOrUpdateSmurfViewModel();
        if (id != null)
        {
            _logger.LogInformation("View for existing smurf is being shown");
            Smurf smurf = _store.GetById(id.Value); // casten naar (Guid) kan ook
            if (smurf == null)
            {
                _logger.LogWarning("Could not find smurf");
                return NotFound();
            }

            viewModel.Smurf = smurf;
        }
        else
        {
            _logger.LogInformation("View for new smurf is being shown");
        }

        return View(viewModel);
    }

    [HttpPost]
    public IActionResult AddOrUpdate(Guid? id, AddOrUpdateSmurfViewModel model)
    {
        if (!ModelState.IsValid)
        {
            _logger.LogWarning("Model state is invalid");
            return View(model);
        }

        _logger.LogInformation("Adding or updating smurf");

        _store.AddOrUpdate(model.Smurf);

        _logger.LogInformation("Smurf successfully added or updated");

        return RedirectToAction("Index", "Home");
    }
}