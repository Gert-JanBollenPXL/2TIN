using AngleSharp.Html.Dom;
using AngleSharp.Html.Parser;
using ContactManager.Tests.Util;
using Guts.Client.Core;
using System.Net;

namespace SmurfApp.Web.Tests;

[ExerciseTestFixture("dotnet2", "4-ViewsAndForms", "SmurfApp",
    @"SmurfApp.Web\Controllers\SmurfController.cs")]
public class SmurfIntegrationTests
{
    private CustomWebApplicationFactory _factory = null!;
    private HttpClient _client = null!;

    [OneTimeSetUp]
    public void BeforeAllTests()
    {
        _factory = new CustomWebApplicationFactory();
        _client = _factory.CreateClient();
    }

    [OneTimeTearDown]
    public void AfterAllTests()
    {
        _factory?.Dispose();
        _client?.Dispose();
    }

    [MonitoredTest]
    public async Task AddOrUpdatePage_NoSmurfId_ShouldHaveAForm()
    {
        IHtmlDocument document = await GetAddOrUpdatePageHtml();

        IHtmlFormElement? form = document.QuerySelector("form") as IHtmlFormElement;
        Assert.That(form, Is.Not.Null, "There should be a form on the AddOrUpdate page");
        ValidateFormElements(form!);
    }

    [MonitoredTest]
    public async Task AddOrUpdatePage_ExistingSmurfId_ShouldHaveAForm()
    {
        var papaSmurfId = Guid.Parse("7bd2c98e-8e90-4f50-9f7e-2fd9b5ce36f0");
        IHtmlDocument document = await GetAddOrUpdatePageHtml(papaSmurfId);

        IHtmlFormElement? form = document.QuerySelector("form") as IHtmlFormElement;
        Assert.That(form, Is.Not.Null, "There should be a form on the AddOrUpdate page");
        ValidateFormElements(form!);
    }

    private static void ValidateFormElements(IHtmlFormElement form)
    {
        var labels = form.QuerySelectorAll("label");
        Assert.That(labels.Length, Is.EqualTo(4), "The form should have 4 labels for its input fields");
        foreach (var label in labels)
        {
            Assert.That(label.GetAttribute("for"), Is.Not.Null.Or.Empty, "All labels should have a 'for' attribute");
        }
        var nameInput = form.QuerySelector("input[name='Smurf.Name']") as IHtmlInputElement;
        Assert.That(nameInput, Is.Not.Null, "The form should have an input field for the Smurf's Name");

        var ageInput = form.QuerySelector("input[name='Smurf.Age']") as IHtmlInputElement;
        Assert.That(ageInput, Is.Not.Null, "The form should have an input field for the Smurf's Age");

        var imageUrlInput = form.QuerySelector("input[name='Smurf.ImageUrl']") as IHtmlInputElement;
        Assert.That(imageUrlInput, Is.Not.Null, "The form should have an input field for the Smurf's ImageUrl");

        var categorySelect = form.QuerySelector("select[name='Smurf.Category']") as IHtmlSelectElement;
        Assert.That(categorySelect, Is.Not.Null, "The form should have a select field for the Smurf's Category");
        var options = categorySelect.QuerySelectorAll("option");
        string[] expectedCategories = Enum.GetNames<Domain.Category>();
        Assert.That(expectedCategories.All(ec => options.Any(o => o.GetAttribute("value") == ec)), Is.True, "The select should have options for all categories");
        Assert.That(options[0].TextContent.Trim(), Is.EqualTo("-- Select a category --"), "The first option in the select should be '-- Select a category --'");
        Assert.That(options[0].HasAttribute("disabled"), Is.True, "The first option in the select should be disabled");
    }

    private async Task<IHtmlDocument> GetAddOrUpdatePageHtml(Guid? smurfId = null)
    {
        string url = smurfId is null ? "/Smurf/AddOrUpdate" : $"/Smurf/AddOrUpdate/{smurfId}";

        HttpResponseMessage response = await _client.GetAsync(url);
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), $"No 200 response when navigating to AddOrUpdate page ({url})");

        string content = await response.Content.ReadAsStringAsync();
        var parser = new HtmlParser();
        IHtmlDocument document = parser.ParseDocument(content);
        return document;
    }
}