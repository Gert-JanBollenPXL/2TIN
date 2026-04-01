using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace QuizApplication.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class seeding : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Questions",
                columns: new[] { "Id", "CategoryId", "QuestionString" },
                values: new object[,]
                {
                    { 1, 4, "What is the capital of France?" },
                    { 2, 3, "Which planet is known as the 'Red Planet'?" },
                    { 3, 2, "Who wrote the play 'Romeo and Juliet'?" },
                    { 4, 3, "What is the closest planet to the sun?" },
                    { 5, 1, "Which gas do plants absorb from the atmosphere during photosynthesis?" },
                    { 6, 2, "Who painted the Mona Lisa?" },
                    { 7, 1, "What is the largest mammal in the world?" },
                    { 8, 4, "What is the capital of Japan?" },
                    { 9, 1, "Which gas do humans exhale when they breathe?" },
                    { 10, 1, "What is the largest organ in the human body?" }
                });

            migrationBuilder.InsertData(
                table: "Answers",
                columns: new[] { "Id", "AnswerText", "IsCorrect", "QuestionId" },
                values: new object[,]
                {
                    { 1, "Rome", false, 1 },
                    { 2, "Madrid", false, 1 },
                    { 3, "Berlin", false, 1 },
                    { 4, "Brussels", false, 1 },
                    { 5, "Jupiter", false, 2 },
                    { 6, "Venus", false, 2 },
                    { 7, "Mars", true, 2 },
                    { 8, "Saturn", false, 2 },
                    { 9, "Charles Dickens", false, 3 },
                    { 10, "William Shakespeare", true, 3 },
                    { 11, "Jane Austen", false, 3 },
                    { 12, "Mark Twain", false, 3 },
                    { 13, "Mercury", true, 4 },
                    { 14, "Uranus", false, 4 },
                    { 15, "Neptunus", false, 4 },
                    { 16, "Earth", false, 4 },
                    { 17, "Oxygen", false, 5 },
                    { 18, "Nitrogen", false, 5 },
                    { 19, "Carbon dioxide", true, 5 },
                    { 20, "Hydrogen", false, 5 },
                    { 21, "Vincent van Gogh", false, 6 },
                    { 22, "Pablo Picasso", false, 6 },
                    { 23, "Leonardo da Vinci", true, 6 },
                    { 24, "Michelangelo", false, 6 },
                    { 25, "Elephant", false, 7 },
                    { 26, "Giraffe", false, 7 },
                    { 27, "Blue whale", true, 7 },
                    { 28, "Lion", false, 7 },
                    { 29, "Beijing", false, 8 },
                    { 30, "Seoul", false, 8 },
                    { 31, "Shanghai", false, 8 },
                    { 32, "Tokyo", true, 8 },
                    { 33, "Oxygen", false, 9 },
                    { 34, "Carbon dioxide", true, 9 },
                    { 35, "Hydrogen", false, 9 },
                    { 36, "Nitrogen", false, 9 },
                    { 37, "Brain", false, 10 },
                    { 38, "Skin", true, 10 },
                    { 39, "Heart", false, 10 },
                    { 40, "Liver", false, 10 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 36);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 38);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 39);

            migrationBuilder.DeleteData(
                table: "Answers",
                keyColumn: "Id",
                keyValue: 40);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 10);
        }
    }
}
