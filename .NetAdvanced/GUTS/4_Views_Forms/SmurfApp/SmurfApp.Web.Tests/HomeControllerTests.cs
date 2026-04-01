using Guts.Client.Core;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using SmurfApp.AppLogic;
using SmurfApp.Domain;
using SmurfApp.Web.Controllers;

namespace SmurfApp.Web.Tests;

[ExerciseTestFixture("dotnet2", "4-ViewsAndForms", "SmurfApp",
    @"SmurfApp.Web\Controllers\HomeController.cs")]
public class HomeControllerTests
{
    private Mock<ILogger<HomeController>> _loggerMock = null!;
    private Mock<ISmurfStore> _smurfStoreMock = null!;
    private HomeController _controller = null!;

    [SetUp]
    public void BeforeEachTest()
    {
        _loggerMock = new Mock<ILogger<HomeController>>();
        _smurfStoreMock = new Mock<ISmurfStore>();
        _controller = new HomeController(_loggerMock.Object, _smurfStoreMock.Object);
    }

    [TearDown] public void AfterEachTest() 
    { 
        _controller?.Dispose();
    }

    [MonitoredTest]
    public void Index_ShouldCallGetAllOnSmurfStore()
    {
        // Arrange
        var smurfs = new List<Smurf>
        {
            new Smurf { Name = "Papa Smurf", Age = 542, Category = Category.Leader },
            new Smurf { Name = "Smurfette", Age = 150, Category = Category.Emotional }
        };
        _smurfStoreMock.Setup(s => s.GetAll()).Returns(smurfs);

        // Act
        var result = _controller.Index() as ViewResult;

        // Assert
        Assert.That(result, Is.Not.Null, "Index should return a ViewResult");
        Assert.That(result.Model, Is.SameAs(smurfs), "The Model of the View should contain the list of smurfs returned by the store.");
    }

    [MonitoredTest]
    public void Index_ShouldLogInformation()
    {
        // Arrange
        var smurfs = new List<Smurf>();
        _smurfStoreMock.Setup(s => s.GetAll()).Returns(smurfs);

        // Act
        _controller.Index();

        // Assert
        _loggerMock.Verify(
            x => x.Log(
                LogLevel.Information,
                It.IsAny<EventId>(),
                It.Is<It.IsAnyType>((v, t) => v.ToString()!.ToLower().Contains("smurfs")),
                It.IsAny<Exception>(),
                It.IsAny<Func<It.IsAnyType, Exception?, string>>()),
            Times.Once,
            "Logger should log an information message when fetching smurfs (the word 'smurfs' should be in the message).");
    }
}