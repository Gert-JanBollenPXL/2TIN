using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Razor.TagHelpers;
using SmurfApp.AppLogic;
using SmurfApp.Domain;
using SmurfApp.Web.Models;

namespace SmurfApp.Web.Controllers;

public class HomeController : Controller
{
    private readonly ISmurfStore _store;
    private readonly ILogger _logger;
    public HomeController(ILogger<HomeController> logger, ISmurfStore smurfStore)
    {
        _logger = logger;
        _store = smurfStore;
    }

    public IActionResult Index()
    {
        _logger.LogInformation("Smurfs are being fetched!");
        var smurfs = _store.GetAll();
        return View(smurfs);
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}