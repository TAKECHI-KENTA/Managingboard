
// 資金収支//
// 	            var xValue = ['10月', '11月', '12月','1月'];
// 	            var y1Value = [20, 14, 23, 25];
// 	            var y2Value = [12, 18, 29, 18];
// 	            var trace1 = {
//                 x: xValue,
//                 y: y1Value,
//                 name: '収入',
//                 type: 'bar',
//                 text: y1Value.map(String),
//                 textposition: 'auto',
//                 hoverinfo: 'none',
//                 marker: {
//                   color: 'rgba(170, 200, 255, 1)'
//                 }
//                 };

//               var trace2 = {
//                 x: xValue,
//                 y: y2Value,
//                 name: '支出',
//                 type: 'bar',
//                 text: y2Value.map(String),
//                 textposition: 'auto',
//                 hoverinfo: 'none',
//                 marker: {
//                   color: 'rgba(255, 184, 162, 1)'
//                 }
//                 };

//               var data = [trace1, trace2];
//               var layout = {
//                 barmode: 'group',
//                 legend: {
//                   x: 0.5,
//                   xanchor: 'center',
//                   y: -0.4,
//                   yanchor: 'bottom',
//                   orientation: 'h',
//                   font: {
//                     size: 10
//                   },
//                   itemclick: 'toggleothers'
//                 },
//                 margin: {
//                   b: 0,
//                   l: 20,
//                   r: 0,
//                   t: 10
//                 },
//                 height: 175
//               };
//               var config = {
//                 responsive: true,
//                 displayModeBar: false
//               };
//               Plotly.newPlot('tester', data, layout, config);



// //  未決済内訳
//       var x1Value = [10];
//       var x2Value = [1279];
//       var yValue = [''];
//       var trace1 = {
//         x: x1Value,
//         y: yValue,
//         name: '期限到来+未設定',
//         type: 'bar',
//         orientation: 'h',
//         text: x1Value.map(String),
//         textposition: 'auto',
//         insidetextanchor: 'middle',
//         hoverinfo: 'x',
//         marker: {
//           color: 'rgba(250, 100, 20, 1)'
//           }
//       };
//       var trace2 = {
//         x: x2Value,
//         y: yValue,
//         name: '期限未到来',
//         type: 'bar',
//         orientation: 'h',
//         text: x2Value.map(String),
//         textposition: 'auto',
//         insidetextanchor: 'middle',
//         hoverinfo: 'x',
//         marker: {
//           color: 'rgba(217, 217, 217, 1)'
//           }
//       };
//       var data = [trace1, trace2];
//       var layout = {
//         barmode: 'stack',
//         legend: {
//                   x: 0.5,
//                   xanchor: 'center',
//                   y: -2,
//                   yanchor: 'bottom',
//                   orientation: 'h',
//                   font: {
//                     size: 10
//                   },
//                   traceorder: 'normal',
//                   itemclick: 'toggleothers'
//         },
//         xaxis: {
//           showgrid: false,
//           showticklabels: false
//         },
//         margin: {
//           t: 0,
//           r: 0,
//           b: 0,
//           l: 20
//         },
//         height: 87
//       };
//       var config = {
//         responsive: true,
//         displayModeBar: false
//       };
//       Plotly.newPlot('receivable_chart', data, layout, config)


//  // 未決済内訳（支払）
//       var x1Value = [543];
//       var x2Value = [1000];
//       var yValue = [''];
//       var trace1 = {
//         x: x1Value,
//         y: yValue,
//         name: '期限到来+未設定',
//         type: 'bar',
//         orientation: 'h',
//         text: x1Value.map(String),
//         textposition: 'auto',
//         insidetextanchor: 'middle',
//         hoverinfo: 'x',
//         marker: {
//           color: 'rgba(250, 100, 20, 1)'
//           }
//       };
//       var trace2 = {
//         x: x2Value,
//         y: yValue,
//         name: '期限未到来',
//         type: 'bar',
//         orientation: 'h',
//         text: x2Value.map(String),
//         textposition: 'auto',
//         insidetextanchor: 'middle',
//         hoverinfo: 'x',
//         marker: {
//           color: 'rgba(217, 217, 217, 1)'
//           }
//       };
//       var data = [trace1, trace2];
//       var layout = {
//         barmode: 'stack',
//         legend: {
//                   x: 0.5,
//                   xanchor: 'center',
//                   y: -2,
//                   yanchor: 'bottom',
//                   orientation: 'h',
//                   font: {
//                     size: 10
//                   },
//                   traceorder: 'normal',
//                   itemclick: 'toggleothers'
//         },
//         xaxis: {
//           showgrid: false,
//           showticklabels: false
//         },
//         margin: {
//           t: 0,
//           r: 0,
//           b: 0,
//           l: 20
//         },
//         height: 87
//       };
//       var config = {
//         responsive: true,
//         displayModeBar: false
//       };
//       Plotly.newPlot('payable_chart', data, layout, config)


// // 営業利益
//       var xValue = ['8月', '9月', '10月','11月','12月','1月'];
//       var yValue = [-1328, -4350, 345, 6054, -120 ,-12459];
//       var trace1 = {
//         x: xValue,
//         y: yValue,
//         name: '営業損益',
//         type: 'scatter',
//         mode: 'lines+markers',
//         textposition: 'bottom center',
//         hoverinfo: 'x+y'
//       };

//       var data = [trace1];

//       var layout = {
//         showlegend: false,
//         yaxis: {
//           rangemode: 'tozero',
//           autorange: true
//           },
//         margin: {
//           t: 5,
//           r: 25,
//           b: 25,
//           l: 25
//         },
//         height: 175
//       };

//       var config = {
//         responsive: true,
//         displayModeBar: false
//       };

//       Plotly.newPlot('operating_profit_chart', data, layout, config)


// // 収益内訳
//       var xValue = ['8月','9月','10月','11月','12月','1月'];
//       var yValue = [3323,1895,7543,8904,9732,6459];

//       var trace1 = {
//         x: xValue,
//         y: yValue,
//         name: '収益',
//         type: 'scatter',
//         mode: 'lines+markers',
//         textposition: 'bottom center',
//         hoverinfo: 'x+y'
//       };

//       var data = [trace1];

//       var layout = {
//         showlegend: false,
//         yaxis: {
//           rangemode: 'tozero',
//           autorange: true
//           },
//         margin: {
//           t: 5,
//           r: 25,
//           b: 25,
//           l: 25
//         },
//         height: 175
//       };

//       var config = {
//         responsive: true,
//         displayModeBar: false
//       };

//       Plotly.newPlot('revenue_chart', data, layout, config)


//  //  費用内訳
//       var allValues = [19, 26, 55, 8, 24, 3, 4, 41];
//       var allLabels = ['売上原価', '販売手数料', '地代家賃','水道光熱費','旅費交通費','交際費','雑費','その他'];

//       var data = [{
//         values: allValues,
//         labels: allLabels,
//         type: 'pie',
//         textposition: 'inside',
//         insidetextanchor: 'middle',
//         hoverinfo: 'label+value+percent',
//         direction: 'clockwise',
//         sort: true
//       }];

//       var layout = {
//         legend: {
//           itemclick: false,
//           font: {
//             size: 10
//           }
//         },
//         margin: {
//           t: 0,
//           r: 5,
//           b: 15,
//           l: 15
//         },
//         height: 175
//       };

//       var config = {
//         responsive: true,
//         displayModeBar: false
//       };

//       Plotly.newPlot('cost_chart', data, layout, config);