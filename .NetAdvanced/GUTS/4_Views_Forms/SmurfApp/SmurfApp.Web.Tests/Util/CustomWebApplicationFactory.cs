using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using SmurfApp.Infrastructure;
using SmurfApp.Web;

namespace ContactManager.Tests.Util;

public class CustomWebApplicationFactory(Action<IServiceCollection>? overrideDependencies = null)
    : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseTestServer();
        builder.ConfigureTestServices(services =>
        {
            overrideDependencies?.Invoke(services);

            // Remove the existing DbContext registration
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<SmurfDbContext>));
            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Build configuration to read from testsettings.json and environment variables
            var configuration = new ConfigurationBuilder()
                .AddJsonFile("testsettings.json", optional: false)
                .AddEnvironmentVariables()
                .Build();

            // Replace the database with test database
            services.AddDbContext<SmurfDbContext>(options =>
            {
                string connectionString = configuration.GetConnectionString("TestDatabase")!;
                options.UseSqlServer(connectionString).EnableSensitiveDataLogging(true);
            });

            var serviceProvider = services.BuildServiceProvider();

            using var scope = serviceProvider.CreateScope();
            var scopedServices = scope.ServiceProvider;
            var dbContext = scopedServices.GetRequiredService<SmurfDbContext>();

            dbContext.Database.EnsureDeleted();
            dbContext.Database.Migrate();
        });
    }

}