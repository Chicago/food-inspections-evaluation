$(function () {
    $('#chart').highcharts({
        chart: {
            type: 'column'
        },
        title: {
            text: 'Percentage of critical violations<br />found in the first half of work',
            style: {fontFamily: 'Rockwell, Rokkitt, Courier Bold, Courier, Georgia, Times, Times New Roman, serif',
                    fontWeight: 'bold'}
        },
        xAxis: {
            type: 'category',
            labels: {
                style: {
                    fontSize: '13px',
                    fontFamily: 'Futura, Futura-Medium, Futura Medium, Century Gothic, CenturyGothic, Apple Gothic, AppleGothic, URW Gothic L, Avant Garde, Questrial, sans-serif'
                }
            }
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Percentage',
                style: {fontFamily: 'Futura, Futura-Medium, Futura Medium, Century Gothic, CenturyGothic, Apple Gothic, AppleGothic, URW Gothic L, Avant Garde, Questrial, sans-serif'}
            }
        },
        legend: {
            enabled: false
        },
        tooltip: {
            pointFormat: 'Percentage of critical violations <br />in the first half of work: <b>{point.y:.1f}%</b>'
        },
        series: [{
            name: 'Percentage of critical violations found in the first month',
            data: [
                ['Business-as-usual Workflow', 55.0],
                ['Data-driven Workflow', 69.0]
            ],
            dataLabels: {
                enabled: false,
                rotation: -90,
                color: '#FFFFFF',
                align: 'right',
                x: 4,
                y: 10,
                style: {
                    fontSize: '13px',
                    fontFamily: 'Futura, Futura-Medium, Futura Medium, Century Gothic, CenturyGothic, Apple Gothic, AppleGothic, URW Gothic L, Avant Garde, Questrial, sans-serif',
                    textShadow: '0 0 3px black'
                }
            }
        }]
    });
});
