// getcompany.jsからJSONデータを持ってきて、その中のdisplay_nameをtextに代入したいが、constがあるとfunctionが働かなくなる
/* 
const {getCompanies} = require('./company/getcompany')
$(function() {
    $("#Company_name").text(getCompanies.display_name)
  })
  
*/

$(function() {
    $("#Company_name").text("jQuery稼働テスト")
  })