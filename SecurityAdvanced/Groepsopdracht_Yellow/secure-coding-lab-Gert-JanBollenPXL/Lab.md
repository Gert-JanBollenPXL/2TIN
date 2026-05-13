# SECURE CODING

For this assignment you are going to fix one leaky boat! Our client hired a pent tester to analyze their application. The web application in question is a Flutter frontend, supported by a Node.js express backend and a Postgresql database. The client thought it would be a good idea to roll their own security. It never is. 

## The environment
Let's take a look at the files we've been given. We have access to all the source code and a docker compose file to help test the app. If you would like to test the app for yourself you can do so with the following command (if you have docker installed):

    docker compose up --build

The web app will then be available on `localhost:8080`. It is also important to note that a few shortcuts were taken to make this assignment a little easier to manipulate. Take a look at the dockerfile for the frontend, for example. You'll note that the frontend is begin built as well as being deployed. In reality, we would like the build process and the deployment to be seperate. There are also more security risks in this app than the risks shown below. The application doesn't utilize https, making it very vulnerable to man in the middle attacks, for example. We encourage you to go hunting for yourself! 

## RISK #1: SQL Injection
Our pen tester noted that it is possible to gain access to the database using SQL Injection.

![task](./task.png) Use SQL Injection to gain access to the secret message. Document which command you used.

![task](./task.png) Fix the backend so user input is sanitized.

## RISK #2: Insecure Storage
The passwords are stored in plaintext in our database. That's a big problem. The client, however, refuses to migrate to a third party solution. 

![task](./task.png) Make sure the passwords in the database are encrypted.

![task](./task.png) Make sure your solution doesn't break the login screen!

## RISK #3: CORS
Our database can be queried from anywhere. We would like to avoid this by using CORS.

![task](./task.png) Research CORS. How can it help us?

![task](./task.png) Make sure CORS is used so our backend can only be used by our frontend.

## RISK #4: Credentials in Version Control
Right now, there are a whole lot of credentials hidden in the dockerfiles but also our backend code. These files are usually a part of our version control, making our credentials easy to track down.

![task](./task.png) We don't want our credentials in our dockerfiles or our docker compose file. How can we avoid this? Our solution should not be a part of the version control system.

![task](./task.png) Use the same solution to remove the credentials from the backend.

![task](./task.png) The damage has been done. Our credentials are exposed in an earlier commit of our version control. What would you recommend?

