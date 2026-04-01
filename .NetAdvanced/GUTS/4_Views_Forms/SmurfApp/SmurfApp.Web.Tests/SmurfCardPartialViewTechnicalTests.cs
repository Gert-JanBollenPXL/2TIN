using Guts.Client.Core;
using Guts.Client.Core.TestTools;
using SmurfApp.Domain;

namespace SmurfApp.Web.Tests;

[ExerciseTestFixture("dotnet2", "4-ViewsAndForms", "SmurfApp")]
public class SmurfCardPartialViewTechnicalTests
{
    private string _partialView = string.Empty;

    [OneTimeSetUp]
    public void BeforeAllTests()
    {
        try
        {
            string webProjectPath = Path.Combine(Solution.Current.Path, "SmurfApp.Web");
            // Find a file named "_SmurfCard.cshtml" in webProjectPath
            string? filePath = Directory.GetFiles(webProjectPath, "_SmurfCard.cshtml", SearchOption.AllDirectories).FirstOrDefault();
            if (filePath is not null)
            {
                _partialView = File.ReadAllText(filePath);
            }
        }
        catch
        {
            // Ignore
        }
    }

    [MonitoredTest]
    public void PartialView_ShouldUseAModelDirective()
    {
        Assert.That(_partialView, Is.Not.Empty, "The _SmurfCard.cshtml partial view could not be found (or is completely empty). Make sure the file exists.");
        Assert.That(_partialView, Does.Contain("@model Smurf"), "The @model directive should be used to indicate that the Model of the View is of type 'Smurf'. " +
                                                                "Tip you can avoid having to use namespaces with '_ViewImports'.");
    }

    [MonitoredTest]
    public void PartialView_ShouldUseTheModel()
    {
        Assert.That(_partialView, Is.Not.Empty, "The _SmurfCard.cshtml partial view could not be found (or is completely empty). Make sure the file exists.");
        Assert.That(_partialView, Does.Contain("@Model."), "The 'Model' property should be used to retrieve properties of the model.");
        string[] smurfProperties = [nameof(Smurf.Name), nameof(Smurf.Age), nameof(Smurf.ImageUrl), nameof(Smurf.Category), nameof(Smurf.Id)]; 
        foreach (string property in smurfProperties)
        {
            Assert.That(_partialView, Does.Contain($".{property}"), $"The partial view should use the '{property}' property of the Smurf model.");
        }
    }

    [MonitoredTest]
    public void PartialView_ShouldUseTagHelpersForTheDetailsButton()
    {
        Assert.That(_partialView, Is.Not.Empty, "The _SmurfCard.cshtml partial view could not be found. Make sure the file exists in the folder used by convention.");
        Assert.That(_partialView, Does.Not.Contain("href").IgnoreCase, "Use tag helpers like 'asp-controller' instead of setting href attributes.");
    }
}