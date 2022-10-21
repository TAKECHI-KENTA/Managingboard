$(function () {
  $("#modal-open").click(function () {
    $("#modal-overlay, #modal-window").fadeIn("fast");
  });
  $("#modal-window").draggable();
  $("#modal-overlay").click(function () {
    $("#modal-overlay, #modal-window").fadeOut("fast");
  });
});
