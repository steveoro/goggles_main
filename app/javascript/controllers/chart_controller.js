import { Controller } from '@hotwired/stimulus'
import Chart from 'chart.js/auto'

/**
 * Array of distinct colors to be used for the chart lines or areas
 */
export const CHART_COLORS = {
  bluelight: '#6767ff',
  blue: '#007bff',
  bluedark: '#0000ff',
  indigo: '#6610f2',
  purple: '#6f42c1',
  pink: '#e83e8c',
  redlight: '#ff6767',
  red: '#dc3545',
  reddark: '#ff0000',
  orange: '#fd7e14',
  yellow: '#ffc107',
  greenlight2: '#99ff99',
  greenlight: '#67ff67',
  green: '#28a745',
  greendark: '#00ff00',
  teal: '#20c997',
  cyan: '#17a2b8',
  greylight: '#999999',
  grey: '#6c757d',
  greydark: '#343a40',
  light: '#f8f9fa',
  dark: '#343a40'
}

/**
 * = Chart.js setup for graphic reports - StimulusJS controller =
 *
 * Simply sets the base configuration for the Chart.js-based chart report
 * using the StimulusJS configuration helpers.
 *
 * == Targets ==
 * @param {String} 'data-chart-target': 'chart' => DOM ID of the target canvas
 *                 (target for this controller instance)
 *
 * == Values ==
 * (Put values directly on controller elements as JSON values that will be parsed by this controller)
 *
 * @param {Array} 'data-chart-type-value' (String, optional: default 'pie')
 *                Actual type of the chart: 'pie', 'line', ...
 *
 * @param {Array} 'data-chart-data1-title-value' (String, optional)
 *                 title for the dataset Array #1 of the chart
 *
 * @param {Array} 'data-chart-data1-value' (Array of Objects, required)
 *                 dataset Array #1 of the chart
 *                (See https://www.chartjs.org/docs/latest/general/data-structures.html for more info about the datasets)
 *
 * @param {Array} 'data-chart-data2-title-value' (String, optional)
 *                 title for the dataset Array #1 of the chart
 *
 * @param {Array} 'data-chart-data2-value' (Array of Objects, optional)
 *                 dataset Array #2 of the chart; when present it can be rendered together with dataset #1
 *
 * == Actions:
 * (no actions, just setup)
 *
 * @author Steve A.
 */
export default class extends Controller {
  static targets = ['chart']
  static values = {
    type: String,
    data1Title: String,
    data1: Array,
    data2Title: String,
    data2: Array
  }

  /**
   * Setup invoked each time the controller instance connects.
   */
  connect () {
    if (this.hasChartTarget && this.hasData1Value) {
      /* eslint-disable no-new */
      // DEBUG
      // console.log('Target & min values found. Setting up chart...')
      const chartType = this.hasTypeValue ? this.typeValue : 'pie'
      new Chart(this.chartTarget, this.prepareConfig(chartType))
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Prepares the options object for the chart depending on the type of chart specified on the controller
   * bindings (defaults to 'pie').
   *
   * @param {String} chartType, the type of chart ('pie' or 'line').
   * @returns a configuration options Object. See:
   *          - https://www.chartjs.org/docs/latest/charts/doughnut.html
   *          - https://www.chartjs.org/docs/latest/charts/line.html
   */
  prepareConfig (chartType) {
    const ctrl = this
    const title1 = this.hasData1TitleValue ? this.data1TitleValue : null
    const title2 = this.hasData2TitleValue ? this.data2TitleValue : null
    const dataset1 = this.hasData1Value ? this.data1Value : null
    const dataset2 = this.hasData2Value ? this.data2Value : null

    return {
      type: chartType,
      data: ctrl.prepareDatasets(chartType, title1, title2, dataset1, dataset2),
      options: {
        responsive: true,
        interaction: ctrl.prepareChartInteraction(chartType),
        plugins: ctrl.prepareChartPlugins(chartType),
        scales: ctrl.prepareChartScales(chartType)
      }
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Prepares the data object for the chart with default options for each dataset depending on the
   * bindings found on the controller instance.
   *
   * @param {String} chartType, the type of chart ('pie' or 'line').
   * @param {String} title1, the title for the dataset Array #1 of the chart (can be null).
   * @param {String} title2, the title for the dataset Array #2 of the chart (can be null).
   * @param {Array} dataset1, the dataset Array #1.
   * @param {Array} dataset2, the dataset Array #2 (can be null).
   * @returns the compound data Object for the chart; see: https://www.chartjs.org/docs/latest/general/data-structures.html
   */
  prepareDatasets (chartType, title1, title2, dataset1, dataset2) {
    if (chartType === 'pie') {
      const datasets = [
        {
          borderWidth: 0.1,
          backgroundColor: Object.values(CHART_COLORS),
          data: dataset1
        },
        {
          borderWidth: 1,
          backgroundColor: Object.values(CHART_COLORS),
          data: dataset2
        }
      ]
      return {
        labels: dataset1.map(item => item.key),
        datasets: datasets
      }
    }

    const datasets = [
      {
        label: title1,
        tension: 0.3,
        borderColor: CHART_COLORS.greenlight2,
        borderWidth: 1,
        backgroundColor: CHART_COLORS.cyan,
        data: dataset1
      },
      {
        label: title2,
        tension: 0.3,
        borderColor: CHART_COLORS.redlight,
        borderWidth: 1,
        backgroundColor: CHART_COLORS.purple,
        data: dataset2
      }
    ]
    return {
      datasets: datasets
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Getter for the chart-type interaction setup.
   * @param {String} chartType, the type of chart ('pie' or 'line').
   * @returns An Object containing the chart interaction configuration for the specified chart type.
   */
  prepareChartInteraction (chartType) {
    if (chartType === 'pie') {
      return {
        mode: 'index'
      }
    }

    return {
      intersect: false,
      mode: 'nearest'
    }
  }

  /**
   * Getter for the chart-type plugins setup.
   * @param {String} chartType, the type of chart ('pie' or 'line').
   * @returns An Object containing the chart plugins configuration for the specified chart type.
   */
  prepareChartPlugins (chartType) {
    if (chartType === 'pie') {
      return {
        legend: {
          position: 'top'
        },
        tooltip: {
          callbacks: {
            label: (tooltipItem) => {
              // DEBUG
              // console.log('Tooltip items:', tooltipItems)
              // console.log('Tooltip dataIndex:', tooltipItem.dataIndex)
              const obj = tooltipItem.dataset.data[tooltipItem.dataIndex]
              // DEBUG
              // console.log('obj:', obj)
              return `${obj.key}, ${obj.typeLabel} ➡ ${obj.count} (${obj.value}%)`
            }
          }
        }
      }
    }

    return {
      legend: {
        position: 'top'
      },
      tooltip: {
        callbacks: {
          title: (tooltipItems) => {
            // DEBUG
            // console.log('Tooltip items:', tooltipItems)
            const list = []
            tooltipItems.forEach(function (tooltipItem) {
              list.push(tooltipItem.raw.xLabel)
            })
            return list.join(', ')
          },
          label: (tooltipItem) => {
            return tooltipItem.raw.yLabel
          }
        }
      }
    }
  }

  /**
   * Getter for the chart-type scales setup.
   * @param {String} chartType, the type of chart ('pie' or 'line').
   * @returns An Object containing the chart scales configuration for the specified chart type.
   */
  prepareChartScales (chartType) {
    if (chartType === 'pie') {
      return null
    }

    const ctrl = this
    return {
      x: {
        type: 'linear',
        ticks: {
          callback: (value, _index, _ticks) => {
            // DEBUG
            // console.log('Ticks value, idx & ticks:', value, _index, _ticks)
            return ctrl.dateFormatter(value)
          }
        }
      },
      y: {
        reverse: true,
        ticks: {
          callback: (value, _index, _ticks) => {
            return ctrl.timingFormatter(value)
          }
        }
      }
    }
  }
  // ---------------------------------------------------------------------------

  /**
   * Formats the date label for the chart given its ISO format as an integer value.
   *
   * @param {integer} value, a timing value expressed as 1/100ths of a second
   * @returns the corresponding String label for the date (<YYYYmmdd> => <YYYY-mm-dd>)
   */
  dateFormatter (value) {
    const year = Math.floor(value / 10000)
    let remainder = Math.floor(value % 10000)
    const month = Math.floor(remainder / 100)
    remainder = Math.floor(remainder % 100)

    return month === 0 || remainder === 0 ? `${year}` : `${year}-${month}-${remainder}`
  }

  /**
   * Prepares a timing label for the chart given its absolute value in hundredths of seconds.
   *
   * @param {integer} value, a timing value expressed as 1/100ths of a second
   * @returns the corresponding String label for the timing ("[HHh]MM'SS.SS")
   */
  timingFormatter (value) {
    const hours = Math.floor(value / 360000)
    let remainder = Math.floor(value % 360000)
    const minutes = Math.floor(remainder / 6000)
    remainder = Math.floor(remainder % 6000)
    const seconds = Math.floor(remainder / 100)
    const hundredths = Math.floor(remainder % 100)

    let label = hours > 0 ? `${hours}h ` : ''
    const secLabel = seconds.toString().length < 2 ? `0${seconds}` : seconds.toString()
    const hdrLabel = hundredths.toString().length < 2 ? `0${hundredths}` : hundredths.toString()

    if (minutes > 0) {
      label += `${minutes}'${secLabel}"${hdrLabel}`
    } else {
      label += `${secLabel}"${hdrLabel}`
    }

    return label
  }
  // ---------------------------------------------------------------------------
}
