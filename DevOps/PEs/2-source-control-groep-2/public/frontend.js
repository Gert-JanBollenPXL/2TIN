const addButton = document.getElementById('add');
const multiplyButton = document.getElementById('multiply');
const subtractButton = document.getElementById('subtract');
const divideButton = document.getElementById('divide');
const powerOfButton = document.getElementById('power-of');

// Provide eventlistener for add button which in his turn will call the add api endpoint
addButton.addEventListener('click', function(event){
    calculate('add');
});

// Provide eventlistener for multiply button which in his turn will call the multiply api endpoint
multiplyButton.addEventListener('click', function(event){
    calculate('multiply');
});

// Provide eventlistener for subtract button which in his turn will call the subtract api endpoint
subtractButton.addEventListener('click', function(event){
    calculate('subtract');
});

// Provide eventlistener for divide button which in his turn will call the divide api endpoint
divideButton.addEventListener('click', function(event){
    calculate('divide');
});

// Provide eventlistener for power-of button which in his turn will call the power-of api endpoint
powerOfButton.addEventListener('click', function(event){
    calculate('power-of');
})

// builds and API endpoint based on provided operand
// Uses getResultFromApi to call API and show result
function calculate(operand){
    const number1 = document.getElementById('number1').value;
    const number2 = document.getElementById('number2').value;

    const apiUrl = '/calc/' + operand + '/' + number1 + '/' + number2;
    getResultFromApi(apiUrl);

}

// Calls the api endpoint using FetchAPI
// The response is written in the result div
function getResultFromApi(apiUrl){
    let fetchOptions = {
        method: 'GET'
      };
      
    fetch(apiUrl, fetchOptions)
        .then(res => {
            return res.json();
        })
        .then(res => {
            document.getElementById('result').innerHTML = 'The result is: ' + res;
        });

}