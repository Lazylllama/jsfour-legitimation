const gender = {
  "Man": "Male",
  "Kvinna": "Female"
}

$(document).ready(function () {
  // Client listener
  window.addEventListener('message', function (event) {
    if (event.data.action == 'open') {
      var data = event.data.array;
      $('#lastname').text(data.lastname);
      $('#firstname').text(data.firstname);
      $('#sex').text(data.sex.toUpperCase().charAt(0) + '/' + gender[data.sex].toUpperCase().charAt(0));
      $('#height').text('170 CM');
      $('#nationality').text(data.nationality);
      $('#headshot').attr('src', data.headshot);
      $('#personnummer').text(data.personalnumber);
      $('body').show();
    } else if (event.data.action == 'close') {
      $('body').hide();
    }
  });
});
