using Guts.Client.Core;
using Guts.Client.Core.TestTools;

namespace SmurfApp.Web.Tests;

[ExerciseTestFixture("dotnet2", "4-ViewsAndForms", "SmurfApp")]
public class HomeTechnicalTests
{
    private string _indexView = string.Empty;

    [OneTimeSetUp]
    public void BeforeAllTests()
    {
        try
        {
            _indexView = Solution.Current.GetFileContent("SmurfApp.Web/Views/Home/Index.cshtml");


        }
        catch
        {
            // Ignore
        }
    }

    [MonitoredTest]
    public void IndexView_ShouldUsePartialViewForTheSmurfCards()
    {
        Assert.That(_indexView, Is.Not.Empty, "The Index.cshtml view could not be found. Make sure the file exists in the folder used by convention.");
        Assert.That(_indexView, Does.Contain("<partial").IgnoreCase, "The <partial> tag helper should be used");
        Assert.That(_indexView, Does.Not.Contain("class=\"card").IgnoreCase, "There should not be <div>-tags with the 'card' class in this view. " +
                                                                             "Those <div>-tags should be in a partial view");
    }

    [MonitoredTest]
    public void IndexView_ShouldUseALayout()
    {
        Assert.That(_indexView, Is.Not.Empty, "The Index.cshtml view could not be found. Make sure the file exists in the folder used by convention.");
        Assert.That(_indexView, Does.Not.Contain("<html").IgnoreCase, "<html>-tag should not be in the Index view, but in the layout");
        Assert.That(_indexView, Does.Not.Contain("<header").IgnoreCase, "<header>-tag should not be in the Index view, but in the layout");
        Assert.That(_indexView, Does.Not.Contain("<footer").IgnoreCase, "<footer>-tag should not be in the Index view, but in the layout");
    }

    [MonitoredTest]
    public void IndexView_ShouldUseAModelDirective()
    {
        Assert.That(_indexView, Is.Not.Empty, "The Index.cshtml view could not be found. Make sure the file exists in the folder used by convention.");
        Assert.That(_indexView, Does.Contain("@model"), "The @model directive should be used in the Index view");
        Assert.That(_indexView, Does.Contain("IList<Smurf>"), "There should be a 'IList<Smurf>' in the View somewhere. " +
                                                              "Tip you can avoid having to use namespaces with '_ViewImports'.");

    }

    [MonitoredTest]
    public void IndexView_ShouldUseTagHelpersForTheAddNewButton()
    {
        Assert.That(_indexView, Is.Not.Empty, "The Index.cshtml view could not be found. Make sure the file exists in the folder used by convention.");
        Assert.That(_indexView, Does.Not.Contain("href").IgnoreCase, "Use tag helpers like 'asp-controller' instead of setting href attributes.");
    }
}