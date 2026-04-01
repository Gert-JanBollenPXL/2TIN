using Guts.Client.Core;
using Guts.Client.Core.TestTools;

namespace SmurfApp.Web.Tests;

[ExerciseTestFixture("dotnet2", "4-ViewsAndForms", "SmurfApp",
    @"SmurfApp.Web\Views\Shared\_TopNavBar.cshtml")]
public class TopNavBarPartialViewTechnicalTests
{
    private string _layoutView = string.Empty;
    private string _navBarView = string.Empty;

    [OneTimeSetUp]
    public void BeforeAllTests()
    {
        try
        {
            _layoutView = Solution.Current.GetFileContent("SmurfApp.Web/Views/Shared/_Layout.cshtml");
            _navBarView = Solution.Current.GetFileContent("SmurfApp.Web/Views/Shared/_TopNavBar.cshtml");
        }
        catch
        {
            // Ignore
        }
    }

    [MonitoredTest]
    public void LayoutView_ShouldUsePartialViewForTheTopNavigation()
    {
        Assert.That(_layoutView, Does.Contain("<partial").IgnoreCase, "The <partial> tag helper should be used");
        Assert.That(_layoutView, Does.Contain("_TopNavBar").IgnoreCase, "The _TopNavBar partial view should be used in this layout.");
    }

    [MonitoredTest]
    public void PartialView_ShouldUseTagHelpersForTheLinks()
    {
        Assert.That(_navBarView, Does.Not.Contain("href").IgnoreCase, "Use tag helpers like 'asp-controller' instead of setting href attributes.");
        Assert.That(_navBarView, Does.Contain("asp-").IgnoreCase, "Use tag helpers like 'asp-controller'.");
    }

    [MonitoredTest]
    public void PartialView_ShouldUseTagHelperForTheSmurfCountViewComponent()
    {
        Assert.That(_navBarView, Does.Contain("<vc:smurf-count").IgnoreCase, "The <vc:smurf-count> tag helper should be used. " +
                                                                             "Tip: this tag helper is automatically available if there is a 'SmurfCount' ViewComponent in the project and you import '@addTagHelper *, SmurfApp.Web' in the Views");
        Assert.That(_navBarView, Does.Not.Contain("class=\"badge").IgnoreCase, "Do not create the Smurf Count badge manually, you must use a ViewComponent");
    }

}