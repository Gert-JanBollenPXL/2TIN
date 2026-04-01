using Microsoft.EntityFrameworkCore;

using Microsoft.Extensions.FileProviders;
using QuizApplication.AppLogic;
using QuizApplication.AppLogic.Contracts;
using QuizApplication.Infrastructure;
using QuizApplication.Web.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

/* Add DB Context here */
builder.Services.AddDbContext<QuizDbContext>(
options =>
{
string connectionString = builder.Configuration["ConnectionStrings:DevConString"];
options.UseSqlServer(connectionString);
});

/* Add services for the DI here! */
builder.Services.AddScoped<ICategoryRepository, InMemoryCategoryRepository>();
builder.Services.AddScoped<IQuestionRepository, QuestionRepository>();
builder.Services.AddScoped<IQuizService, QuizService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();

/* Please leave this for the Integration tests, you can ignore this: */
public partial class Program { }