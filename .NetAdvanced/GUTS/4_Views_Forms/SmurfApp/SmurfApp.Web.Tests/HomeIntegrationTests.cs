using AngleSharp.Dom;
using AngleSharp.Html.Dom;
using AngleSharp.Html.Parser;
using ContactManager.Tests.Util;
using Guts.Client.Core;
using System.Net;

namespace SmurfApp.Web.Tests;

[ExerciseTestFixture("dotnet2", "4-ViewsAndForms", "SmurfApp",
    @"SmurfApp.Web\Controllers\HomeController.cs")]
public class HomeIntegrationTests
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
    public async Task HomePage_ShouldHaveANavigationBarAtTheTop()
    {
        IHtmlDocument document = await GetHomePageHtml();

        var navElement = document.QuerySelector("nav");
        Assert.That(navElement, Is.Not.Null, "Navigation bar should be present on all pages");
        Assert.That(navElement.QuerySelectorAll("a"), Has.Count.GreaterThanOrEqualTo(2), "There should be at least 2 links in the navigation bar");
    }

    [MonitoredTest]
    public async Task HomePage_ShouldHaveAFooterAtTheBottom()
    {
        IHtmlDocument document = await GetHomePageHtml();

        var footerElement = document.QuerySelector("footer");
        Assert.That(footerElement, Is.Not.Null, "Footer should be present on all pages");
    }


    [MonitoredTest]
    public async Task HomePage_ShouldShowACardForEachSmurf()
    {
        IHtmlDocument document = await GetHomePageHtml();

        IHtmlCollection<IElement> cards = document.QuerySelectorAll("div.card");
        Assert.That(cards.Length, Is.GreaterThanOrEqualTo(10), "At least 10 smurf cards (div.card) should be found on the home page");

        foreach (var card in cards)
        {
            var nameElement = card.QuerySelector("h5.card-title");
            Assert.That(nameElement, Is.Not.Null, "Each card should have a title element with class 'card-title'");
            Assert.That(nameElement!.TextContent, Is.Not.Empty, "Each card title should not be empty");
            var imgElement = card.QuerySelector("img") as IHtmlImageElement;
            Assert.That(imgElement, Is.Not.Null, "Each card should have an image element");
            Assert.That(Uri.IsWellFormedUriString(imgElement!.Source, UriKind.Absolute), Is.True, "Each card image should have a valid absolute URL");

            var detailsLink = card.QuerySelector("a.btn");
            Assert.That(detailsLink, Is.Not.Null, "Each card should have a details link with class 'btn'");
            string? detailsUrl = detailsLink!.GetAttribute("href");
            Assert.That(detailsUrl, Does.StartWith("/Smurf/AddOrUpdate/"), "Each card details link should navigate to /Smurf/AddOrUpdate/{id}");
            Assert.That(Guid.TryParse(detailsUrl!.Split('/').Last(), out _), Is.True, "Each card details link should contain a valid GUID id");
        }
    }

    [MonitoredTest]
    public async Task HomePage_ShouldHaveAButtonToAddANewSmurf()
    {
        IHtmlDocument document = await GetHomePageHtml();

        var addButton = document.QuerySelector("a#add-new");
        Assert.That(addButton, Is.Not.Null, "There should be an a-tag with the id 'add-new'");
        Assert.That(addButton.GetAttribute("href"), Is.EqualTo("/Smurf/AddOrUpdate"), "The add button should navigate to the correct URL");
    }

    [MonitoredTest]
    public async Task HomePage_ShouldHaveASmurfCountInTheNavigation()
    {
        IHtmlDocument document = await GetHomePageHtml();

        var smurfCountSpan = document.QuerySelector("nav span.badge");
        Assert.That(smurfCountSpan, Is.Not.Null, "There should be a span with class 'badge' in the navigation");
        Assert.That(smurfCountSpan!.TextContent, Does.Contain("Smurf Count").IgnoreCase, "The smurf count badge should contain the text 'Smurf Count'");
        Assert.That(smurfCountSpan.TextContent, Does.Contain("10").IgnoreCase, "There should be a count of 10 smurfs");
    }

    private async Task<IHtmlDocument> GetHomePageHtml()
    {
        HttpResponseMessage response = await _client.GetAsync("/Home/Index");
        Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK), "No 200 response when navigating to home page");

        string content = await response.Content.ReadAsStringAsync();
        var parser = new HtmlParser();
        IHtmlDocument document = parser.ParseDocument(content);
        return document;
    }
}