using Guts.Client.Core;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using SmurfApp.AppLogic;
using SmurfApp.Domain;
using SmurfApp.Web.Controllers;
using SmurfApp.Web.Models;

namespace SmurfApp.Web.Tests;

[ExerciseTestFixture("dotnet2", "4-ViewsAndForms", "SmurfApp",
    @"SmurfApp.Web\Controllers\SmurfController.cs")]
public class SmurfControllerTests
{
    private Mock<ILogger<SmurfController>> _loggerMock = null!;
    private Mock<ISmurfStore> _smurfStoreMock = null!;
    private SmurfController _controller = null!;

    [SetUp]
    public void BeforeEachTest()
    {
        _loggerMock = new Mock<ILogger<SmurfController>>();
        _smurfStoreMock = new Mock<ISmurfStore>();
        _controller = new SmurfController(_loggerMock.Object, _smurfStoreMock.Object);
    }

    [TearDown]
    public void AfterEachTest()
    {
        _controller?.Dispose();
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpGet_WithoutId_ShouldReturnViewWithEmptyModel()
    {
        // Act
        var result = _controller.AddOrUpdate(null) as ViewResult;

        // Assert
        Assert.That(result, Is.Not.Null, "AddOrUpdate (GET) should return a ViewResult");
        var model = result!.Model as AddOrUpdateSmurfViewModel;
        Assert.That(model, Is.Not.Null, "Model should be of type AddOrUpdateSmurfViewModel");
        Assert.That(model!.Smurf, Is.Not.Null, "Smurf property should be initialized");
        Assert.That(model.Smurf.Name, Is.Empty, "A new Smurf should have an empty Name");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpGet_WithoutId_ShouldLogInformation()
    {
        // Act
        _controller.AddOrUpdate(null);

        // Assert
        _loggerMock.Verify(
            x => x.Log(
                LogLevel.Information,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.ToLower().Contains("new smurf")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once,
            "Logger should log an information message containing the text 'new smurf'");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpGet_WithValidId_ShouldReturnViewWithExistingSmurf()
    {
        // Arrange
        var smurfId = Guid.NewGuid();
        var existingSmurf = new Smurf
        {
            Id = smurfId,
            Name = "Brainy Smurf",
            Age = 200,
            Category = Category.Skilled
        };
        _smurfStoreMock.Setup(s => s.GetById(smurfId)).Returns(existingSmurf);

        // Act
        var result = _controller.AddOrUpdate(smurfId) as ViewResult;

        // Assert
        Assert.That(result, Is.Not.Null, "AddOrUpdate (GET) should return a ViewResult");
        var model = result!.Model as AddOrUpdateSmurfViewModel;
        Assert.That(model, Is.Not.Null, "Model should be of type AddOrUpdateSmurfViewModel");
        _smurfStoreMock.Verify(s => s.GetById(smurfId), Times.Once, "GetById should be called on the SmurfStore");
        Assert.That(model!.Smurf, Is.SameAs(existingSmurf), "Model should contain the existing smurf from the store");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpGet_WithValidId_ShouldLogInformation()
    {
        // Arrange
        var smurfId = Guid.NewGuid();
        var existingSmurf = new Smurf { Id = smurfId, Name = "Papa Smurf", Age = 542, Category = Category.Leader };
        _smurfStoreMock.Setup(s => s.GetById(smurfId)).Returns(existingSmurf);

        // Act
        _controller.AddOrUpdate(smurfId);

        // Assert
        _loggerMock.Verify(
            x => x.Log(
                LogLevel.Information,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.ToLower().Contains("existing smurf")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once,
            "Logger should log an information message containing the text 'existing smurf'");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpGet_WithInvalidId_ShouldReturnNotFound()
    {
        // Arrange
        var invalidId = Guid.NewGuid();
        _smurfStoreMock.Setup(s => s.GetById(invalidId)).Returns((Smurf?)null);

        // Act
        var result = _controller.AddOrUpdate(invalidId);

        // Assert
        _smurfStoreMock.Verify(s => s.GetById(invalidId), Times.Once, "GetById should be called on the SmurfStore");
        Assert.That(result, Is.InstanceOf<NotFoundResult>(), "Should return NotFound when smurf doesn't exist");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpGet_WithInvalidId_ShouldLogWarning()
    {
        // Arrange
        var invalidId = Guid.NewGuid();
        _smurfStoreMock.Setup(s => s.GetById(invalidId)).Returns((Smurf?)null);

        // Act
        _controller.AddOrUpdate(invalidId);

        // Assert
        _loggerMock.Verify(
            x => x.Log(
                LogLevel.Warning,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.ToLower().Contains("find")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once,
            "Logger should log a warning message containing the text 'find'");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpPost_WithValidModel_ShouldCallAddOrUpdateOnStore()
    {
        // Arrange
        var smurf = new Smurf
        {
            Id = Guid.NewGuid(),
            Name = "Jokey Smurf",
            Age = 175,
            Category = Category.Playful,
            ImageUrl = "https://example.com/jokey.jpg"
        };
        var model = new AddOrUpdateSmurfViewModel { Smurf = smurf };

        // Act
        var result = _controller.AddOrUpdate(smurf.Id, model);

        // Assert
        _smurfStoreMock.Verify(s => s.AddOrUpdate(smurf), Times.Once, "AddOrUpdate should be called on the SmurfStore");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpPost_WithValidModel_ShouldRedirectToHomeIndex()
    {
        // Arrange
        var smurf = new Smurf
        {
            Id = Guid.NewGuid(),
            Name = "Vanity Smurf",
            Age = 150,
            Category = Category.Emotional,
            ImageUrl = "https://example.com/vanity.jpg"
        };
        var model = new AddOrUpdateSmurfViewModel { Smurf = smurf };

        // Act
        var result = _controller.AddOrUpdate(smurf.Id, model) as RedirectToActionResult;

        // Assert
        Assert.That(result, Is.Not.Null, "Should return a RedirectToActionResult");
        Assert.That(result!.ActionName, Is.EqualTo("Index"), "Should redirect to Index action");
        Assert.That(result.ControllerName, Is.EqualTo("Home"), "Should redirect to Home controller");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpPost_WithValidModel_ShouldLogInformation()
    {
        // Arrange
        var smurf = new Smurf
        {
            Id = Guid.NewGuid(),
            Name = "Handy Smurf",
            Age = 250,
            Category = Category.Skilled,
            ImageUrl = "https://example.com/handy.jpg"
        };
        var model = new AddOrUpdateSmurfViewModel { Smurf = smurf };

        // Act
        _controller.AddOrUpdate(smurf.Id, model);

        // Assert
        _loggerMock.Verify(
            x => x.Log(
                LogLevel.Information,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.ToLower().Contains("adding or updating")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once,
            "Logger should log an information message containing the text 'adding or updating'");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpPost_WithInvalidModelState_ShouldReturnView()
    {
        // Arrange
        var model = new AddOrUpdateSmurfViewModel
        {
            Smurf = new Smurf { Name = "", Age = 0 }
        };
        _controller.ModelState.AddModelError("Smurf.Name", "Name is required");

        // Act
        var result = _controller.AddOrUpdate(null, model) as ViewResult;

        // Assert
        Assert.That(result, Is.Not.Null, "Should return a ViewResult when ModelState is invalid");
        Assert.That(result!.Model, Is.SameAs(model), "Should return the same model to the view");
        _smurfStoreMock.Verify(s => s.AddOrUpdate(It.IsAny<Smurf>()), Times.Never,
            "AddOrUpdate should not be called when ModelState is invalid");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpPost_WithInvalidModelState_ShouldLogWarning()
    {
        // Arrange
        var model = new AddOrUpdateSmurfViewModel
        {
            Smurf = new Smurf { Name = "", Age = 0 }
        };
        _controller.ModelState.AddModelError("Smurf.Name", "Name is required");

        // Act
        _controller.AddOrUpdate(null, model);

        // Assert
        _loggerMock.Verify(
            x => x.Log(
                LogLevel.Warning,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => true),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once,
            "Logger should log a warning when ModelState is invalid");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpGetAction_ShouldHaveHttpGetAttribute()
    {
        // Arrange
        var methodInfo = typeof(SmurfController).GetMethods()
            .First(m => m.Name == "AddOrUpdate" && m.GetParameters().Length == 1);

        // Act
        var httpGetAttribute = methodInfo.GetCustomAttributes(typeof(HttpGetAttribute), true)
            .FirstOrDefault() as HttpGetAttribute;

        // Assert
        Assert.That(httpGetAttribute, Is.Not.Null, "The AddOrUpdate (GET) method should have a HttpGet attribute");
    }

    [MonitoredTest]
    public void AddOrUpdate_HttpPostAction_ShouldHaveHttpPostAttribute()
    {
        // Arrange
        var methodInfo = typeof(SmurfController).GetMethods()
            .First(m => m.Name == "AddOrUpdate" && m.GetParameters().Length == 2);

        // Act
        var httpPostAttribute = methodInfo.GetCustomAttributes(typeof(HttpPostAttribute), true)
            .FirstOrDefault() as HttpPostAttribute;

        // Assert
        Assert.That(httpPostAttribute, Is.Not.Null, "The AddOrUpdate (POST) method should have a HttpPost attribute");
    }
}