/*
 *  error.js
 *
 *  Created by Kevin Musselman (kmussel@gmail.com) on 09/13/20
 *  Copyright 2018 Kevin Musselman
 */

import React from 'react'
import PropTypes from 'prop-types'

export default class ErrorHandler extends React.Component {
  static parentStyles = { background: '#fe3b61' };

  renderMessage () {
    var caption = this.props.caption
    var subtext = this.props.subtext

    if (!caption && this.props.requestError) {
      caption = this.props.requestError.message
      if (!subtext) {
        const data = this.props.requestError.data
        if (!data) {
          subtext = 'Uknown Error'
        } else {
          subtext = Object.keys(data).map((key, index) => {
            var item = data[key]
            if (typeof (item) === 'object') {
              item = JSON.stringify(item)
            } else if (Array.isArray(item)) {
              item = item.join(', ')
            }
            return (
              <div key={key} >
                {key}: {item}
              </div>
            )
          })
        }
      }
    }

    return (<div>
      <p className="" aria-label="Error" style={{ fontSize: '22px' }}>{caption || 'An error has occured.'}</p>
      <div className="" style={{ fontSize: '14px' }}>{subtext || ''}</div>
    </div>
    )
  }

  render () {
    return (
      <div className="message is-danger">
        <div className="message-header">
          {this.renderMessage()}
          <button className="delete" aria-label="Dismiss Message" onClick={this.props.dismissAction}></button>
        </div>
      </div>
    )
  }
}

ErrorHandler.propTypes = {
  caption: PropTypes.string,
  subtext: PropTypes.string,
  requestError: PropTypes.object,
  dismissAction: PropTypes.func.isRequired
}
