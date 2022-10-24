$(function () {
  $("#modal-open").click(function () {
    $("#modal-overlay, #modal-window").fadeIn("fast");
  });
  $("#modal-window").draggable(); // ドラッグできるようにならない。ここの書き方が不明
  $("#modal-overlay").click(function () {
    $("#modal-overlay, #modal-window").fadeOut("fast");
  });
}); 

/* $(document).ready(function() {
    $('.open-window').openwin({
        option : {
            width      : 200,
            height     : 200,
            scrollbars : "yes"
        },
        focus  : true
    });
});
*/